<?php
/* This file is part of the XP framework
 *
 * $Id$
 */

  uses(
    'de.thekid.dialog.cmd.ImportCommand',
    'de.thekid.dialog.GroupingStrategy',
    'de.thekid.dialog.Album',
    'de.thekid.dialog.EntryCollection'
  );

  /**
   * Adds collections to dialog Will import a complete directory with 
   * subdirectories containing the (original) images and assumes the 
   * following directory layout:
   * <pre>
   *   + [directory]
   *   |--+ [subdirectory #1]
   *   |  |--+ [highlights]
   *   |  |  |-- image #1
   *   |  |  |-- image #2
   *   |  |  |-- ...
   *   |  |
   *   |  |-- description.txt
   *   |  |-- title.txt
   *   |  |-- image #1
   *   |  |-- image #2
   *   |  |-- ...
   *   |
   *   |--+ [subdirectory #2]
   *   |  |--+ [highlights]
   *   |  |  |-- image #1
   *   |  |  |-- ...
   *   |  |
   *   |  |-- description.txt
   *   |  |-- title.txt
   *   |  |-- image #1
   *   |  |-- ...
   *   |
   *   |--+ ...
   *   |-- description.txt
   * </pre>
   * 
   * It will then follow these rules:
   * 
   * <ul>
   *   <li>The entire text from the file description.txt will be used to
   *     make the text for the front page.
   *
   *   </li><li>The directory's name will be used for the collection's title.
   *     Note: This can be overridden by the command line switch "-t"
   *
   *   </li><li>The directory's creation date will be used for the 
   *     collection's creation timestamp.
   *     Note: This can be overridden by the command line switch "-c"
   *
   *   </li><li>For each of the subdirectories in the origin directory,
   *     an album inside this collection will be created according to the
   *     rules described inside the AddAlbum command.
   * 
   *   </li><li>If a file inside the subdirectory called "title.txt" exists,
   *     then the text inside will be used as the album's title - the sub-
   *     directory's name will be used otherwise.
   *
   *   </li><li>Any non-directory inside the collection directory will be
   *     ignored.
   *
   *   </li><li>The directory's name will be transformed to the collection's 
   *     online name by lowercasing all characters in it and replacing any 
   *     character besides a-z, 0-9 and - by an underscore. Double 
   *     underscores will be replaced by single ones.
   *    
   *     Example: 
   *     "Philippines Vacation 2006" will become "philippines_vacation_2006"
   * 
   *     The online name is used in permalinks.
   *   </li>
   * </ul>
   *
   * @see      xp://de.thekid.dialog.cmd.AddAlbum
   * @purpose  Command
   */
  class AddCollection extends ImportCommand {
    protected
      $origin            = NULL,
      $destination       = NULL,
      $collectionStorage = NULL,
      $collection        = NULL,
      $title             = NULL,
      $createdAt         = NULL;

    /**
     * Set origin folder
     *
     * @param   string folder
     */
    #[@arg(position= 0)]
    public function setOrigin($folder) {
      $this->origin= new Folder($folder);
      if (!$this->origin->exists()) {
        throw new FileNotFoundException('Folder "'.$folder.'" does not exist');
      }
    }
    
    /**
     * Set collection's title. If no title is given and the collection did not 
     * previously exist, uses the origin folder's directory name.
     *
     * @param   string title default NULL
     */
    #[@arg]
    public function setTitle($title= NULL) {
      $this->title= $title;
    }

    /**
     * Set collection's creation date. If no date is given and the collection did not 
     * previously exist, uses the origin folder's creation date.
     *
     * @param   string date default NULL
     */
    #[@arg]
    public function setCreatedAt($date= NULL) {
      $this->createdAt= $date;
    }

    /**
     * Sets how to group images into chapters (one of "hour" or "day")
     *
     * @see     xp://de.thekid.dialog.GroupingStrategy
     * @param   string method default "hour"
     */
    #[@arg]
    public function setGroupBy($method= 'hour') {
      try {
        $this->groupingStrategy= Enum::valueOf(XPClass::forName('de.thekid.dialog.GroupingStrategy'), $method);
      } catch (IllegalArgumentException $e) {
        throw new IllegalArgumentException(sprintf(
          'Unknown grouping method "%s", supported: %s',
          $method,
          xp::stringOf(GroupingStrategy::values())
        ));
      }
      $this->out->writeLine('---> Group by ', $this->groupingStrategy);
    }
    
    /**
     * Import
     *
     */
    protected function doImport() {
      $jpegs= new ExtensionEqualsFilter('.jpg');
      $this->topics= array();

      // Normalize name
      $collectionName= $this->normalizeName($this->origin->dirname);
      $this->out->writeLine('===> Adding collection "', $collectionName, '" from ', $this->origin);
      
      // Create destination folder if not already existant
      $this->destination= new Folder($this->imageFolder->getURI().$collectionName);
      $this->processor->setOutputFolder($this->destination);
      
      // Check if the collection already exists
      $this->collectionStorage= new File($this->dataFolder, $collectionName.'.dat');
      if ($this->collectionStorage->exists()) {
        $this->out->writeLine('---> Found existing collection');
        $this->collection= unserialize(FileUtil::getContents($this->collectionStorage));

        // Entries will be regenated from scratch    
        $this->collection->entries= array();
     } else {
        $this->out->writeLine('---> Creating new collection');
        $this->collection= new EntryCollection();
        $this->collection->setName($collectionName);
      }
      
      // Read the introductory text from description.txt if existant
      if (is_file($df= $this->origin->getURI().'description.txt')) {
        $this->collection->setDescription(file_get_contents($df));
      }

      if (!$this->collection->getCreatedAt() || NULL !== $this->createdAt) {
        $this->collection->setCreatedAt(new Date(NULL === $this->createdAt ? $this->origin->createdAt() : $this->createdAt));
      }
      if (!$this->collection->getTitle() || NULL !== $this->title) {
        $this->collection->setTitle(NULL === $this->title ? $this->origin->dirname : $this->title);
      }
      $this->out->writeLine('---> Created ', $this->collection->getCreatedAt());
      $this->out->writeLine('---> Title "', $this->collection->getTitle(), '"');

      // Create destination directory if not existant
      $this->destination->exists() || $this->destination->create(0755);

      // Iterate on collection's origin folder
      while ($entry= $this->origin->getEntry()) {
        $qualified= $this->origin->getURI().$entry.DIRECTORY_SEPARATOR;
        if (!is_dir($qualified)) continue;
        
        // Create album
        $albumName= $this->normalizeName($entry);
        $this->out->writeLine('     >> Creating album "', $entry, '" (name= "', $albumName, '")');

        $album= $this->collection->addEntry(new Album());
        $album->setName($this->collection->getName().'/'.$albumName);

        // Read the title title.txt if existant, use the directory name otherwise
        if (is_file($tf= $qualified.TITLE_FILE)) {
          $album->setTitle(file_get_contents($tf));
        } else {
          $album->setTitle($entry);
        }

        // Read the introductory text from description.txt if existant
        if (is_file($df= $qualified.DESCRIPTION_FILE)) {
          $album->setDescription(file_get_contents($df));
        }

        // Create destination directory if not existant
        // Point processor at new destination
        $albumDestination= new Folder($this->destination->getURI().$albumname);
        $albumDestination->exists() || $albumDestination->create(0755);
        $this->processor->setOutputFolder($albumDestination);

        // Get highlights
        $highlights= new Folder($qualified.'highlights');
        if ($highlights->exists()) {
          for (
            $it= new FilteredIOCollectionIterator(new FileCollection($highlights->getURI()), $jpegs);
            $it->hasNext();
          ) {
            $highlight= $this->processor->albumImageFor($it->next()->getURI());
            $this->processMetaData($highlight, $album);

            $album->addHighlight($highlight);
            $this->out->writeLine('     >> Added highlight ', $highlight->getName(), ' to album ', $albumName);
          }
          $needsHighlights= self::HIGHLIGHTS_MAX - $album->numHighlights();
        }

        // Process all images
        for (
          $images= array(),
          $it= new FilteredIOCollectionIterator(new FileCollection($qualified), $jpegs);
          $it->hasNext();
        ) {
          $image= $this->processor->albumImageFor($it->next()->getURI());
          $this->processMetaData($image, $album);

          $images[]= $image;
          $this->out->writeLine('     >> Added image ', $image->getName(), ' to album ', $albumName);

          // Check if more highlights are needed
          if ($needsHighlights <= 0) continue;

          $this->out->writeLine('     >> Need ', $needsHighlights, ' more highlight(s) for album ', $albumName, ', using above image');
          $album->addHighlight($image);
          $needsHighlights--;
        }

        // Sort images by their creation date (from EXIF data)
        usort($images, create_function(
          '$a, $b', 
          'return $b->exifData->dateTime->compareTo($a->exifData->dateTime);'
        ));

        // Group images by strategy
        for ($i= 0, $chapter= array(), $s= sizeof($images); $i < $s; $i++) {
          $key= $this->groupingStrategy->groupFor($images[$i]);
          if (!isset($chapter[$key])) {
            $chapter[$key]= $album->addChapter(new AlbumChapter($key));
          }

          $chapter[$key]->addImage($images[$i]);
        }

        // Save album
        $base= dirname($this->destination->getURI()).DIRECTORY_SEPARATOR.$album->getName();
        FileUtil::setContents(new File($base.'.dat'), serialize($album));
        FileUtil::setContents(new File($base.'.idx'), serialize($this->collection->getName()));
      }
    
      // Save collection
      FileUtil::setContents($this->collectionStorage, serialize($this->collection));
    }
  }
?>
