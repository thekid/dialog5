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
   * Adds albums to dialog
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
      $this->destination= new Folder(self::IMAGE_FOLDER.$albumName);
      $this->processor->setOutputFolder($this->destination);
      
      // Check if the album already exists
      $this->albumStorage= new File(self::DATA_FOLDER.$albumName.'.dat');
      if ($this->albumStorage->exists()) {
        $this->out->writeLine('---> Found existing album');
        $this->album= unserialize(FileUtil::getContents($this->albumStorage));

        // Entries will be regenated from scratch    
        $album->highlights= $album->chapters= array();
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
     * Sets how to group images into chapters
     *
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
    
      // Create destination directory if not existant
      $this->destination->exists() || $this->destination->create(0755);
      
      // Get highlights
      $highlights= new Folder($this->origin->getURI().'highlights');
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
