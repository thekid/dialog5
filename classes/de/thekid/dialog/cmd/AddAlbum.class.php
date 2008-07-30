<?php
/* This file is part of the XP framework
 *
 * $Id$
 */

  uses(
    'de.thekid.dialog.cmd.ImportCommand',
    'de.thekid.dialog.GroupingStrategy',
    'de.thekid.dialog.Album'
  );

  /**
   * Adds albums to dialog. Will import a complete directory of (original) 
   * images and assumes the following directory layout:
   * <pre>
   *   + [directory]
   *   |--+ [highlights]
   *   |  |-- image #1
   *   |  |-- image #2
   *   |  |-- ...
   *   |
   *   |-- description.txt
   *   |-- image #1
   *   |-- image #2
   *   |-- ...
   * </pre>
   * 
   * It will then follow these rules:
   * 
   * <ul>
   *   <li>The images from the "highlights" subdirectory will be taken for
   *     the images on the front page. They will be rescaled to 150 x 113
   *     pixels for this purpose.
   *   
   *     If no such directory exists, the script will pick at most 5 images
   *     from the entire directory's contents per random.
   *
   *   </li><li>The entire text from the file description.txt will be used to
   *     make the text for the front page.
   *
   *   </li><li>The directory's name will be used for the album's title.
   *     Note: This can be overridden by the command line switch "-t"
   *
   *   </li><li>The directory's creation date will be used for the album's 
   *     creation timestamp.
   *     Note: This can be overridden by the command line switch "-c"
   *
   *   </li><li>The images from the directory (file mask: *.JPG) will be taken
   *     for the images on the subsequent pages. They will be resized to
   *     150 x 113 pixels for the overview and to 800 x 600 or 600 x 800
   *     pixels (depending on the picture's orientation) for the larger
   *     view.
   *
   *   </li><li>The images are grouped into chapters. The default setting
   *     is to create a chapter for every hour and can be overriddent by
   *     the command line switch "-g".
   *
   *   </li><li>The directory's name will be transformed to the album's online
   *     name by lowercasing all characters in it and replacing any 
   *     character besides a-z, 0-9 and - by an underscore. Double 
   *     underscores will be replaced by single ones.
   *    
   *     Example: 
   *     "Steve's birthday 02/28/2005" will become "steves_birthday_02_28_2005"
   * 
   *     The online name is used in permalinks.
   *   </li>
   * </ul>
   *
   * @purpose  Command
   */
  class AddAlbum extends ImportCommand {
    protected
      $origin           = NULL,
      $destination      = NULL,
      $albumStorage     = NULL,
      $groupingStrategy = NULL,
      $album            = NULL;

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
      
      // Normalize name
      $albumName= $this->normalizeName($this->origin->dirname);
      $this->out->writeLine('===> Adding album "', $albumName, '" from ', $this->origin);
      
      // Create destination folder if not already existant
      $this->destination= new Folder($this->imageFolder.$albumName);
      $this->processor->setOutputFolder($this->destination);
      
      // Check if the album already exists
      $this->albumStorage= new File($this->dataFolder.$albumName.'.dat');
      if ($this->albumStorage->exists()) {
        $this->out->writeLine('---> Found existing album');
        $this->album= unserialize(FileUtil::getContents($this->albumStorage));

        // Entries will be regenated from scratch    
        $this->album->highlights= $this->album->chapters= array();
      } else {
        $this->out->writeLine('---> Creating new album');
        $this->album= new Album();
        $this->album->setName($albumName);
      }        

      // Read the introductory text from description.txt if existant
      if (is_file($df= $this->origin->getURI().'description.txt')) {
        $this->album->setDescription(file_get_contents($df));
      }
    }
    
    /**
     * Set album's title. If no title is given and the album did not 
     * previously exist, uses the origin folder's directory name.
     *
     * @param   string title default NULL
     */
    #[@arg]
    public function setTitle($title= NULL) {
      if (!$title && !$this->album->getTitle()) {
        $this->album->setTitle($this->origin->dirname);
      } else {
        $this->album->setTitle($title);
      }
      $this->out->writeLine('---> Title "', $this->album->getTitle(), '"');
    }

    /**
     * Set album's creation date. If no date is given and the album did not 
     * previously exist, uses the origin folder's creation date.
     *
     * @param   string date default NULL
     */
    #[@arg]
    public function setCreatedAt($date= NULL) {
      if (!$date && !$this->album->getCreatedAt()) {
        $this->album->setCreatedAt(new Date($this->origin->createdAt()));
      } else {
        $this->album->setCreatedAt(new Date($date));
      }
      $this->out->writeLine('---> Created ', $this->album->getCreatedAt());
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
      $jpegs= new AnyOfFilter(array(
        new ExtensionEqualsFilter('.jpg'),
        new ExtensionEqualsFilter('.JPG')
      ));
      $this->topics= array();
    
      // Create destination directory if not existant
      $this->destination->exists() || $this->destination->create(0755);
      
      // Get highlights
      $highlights= new Folder($this->origin->getURI().'highlights');
      $needsHighlights= self::HIGHLIGHTS_MAX;
      if ($highlights->exists()) {
        for (
          $it= new FilteredIOCollectionIterator(new FileCollection($highlights->getURI()), $jpegs);
          $it->hasNext();
        ) {
          $highlight= $this->processor->albumImageFor($it->next()->getURI());
          $this->processMetaData($highlight, $this->album);

          $this->album->addHighlight($highlight);
          $this->out->writeLine('     >> Added highlight ', $highlight->getName());
        }
        $needsHighlights= self::HIGHLIGHTS_MAX - $this->album->numHighlights();
      }
      
      // Process all images
      for (
        $images= array(),
        $it= new FilteredIOCollectionIterator(new FileCollection($this->origin->getURI()), $jpegs);
        $it->hasNext();
      ) {
        $image= $this->processor->albumImageFor($it->next()->getURI());
        $this->processMetaData($image, $this->album);

        $images[]= $image;
        $this->out->writeLine('     >> Added image ', $image->getName());
        
        // Check if more highlights are needed
        if ($needsHighlights <= 0) continue;

        $this->out->writeLine('     >> Need ', $needsHighlights, ' more highlight(s), using above image');
        $this->album->addHighlight($image);
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
          $chapter[$key]= $this->album->addChapter(new AlbumChapter($key));
        }

        $chapter[$key]->addImage($images[$i]);
      }
      
      // Save album and topics
      FileUtil::setContents($this->albumStorage, serialize($this->album));
    }
  }
?>
