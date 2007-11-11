<?php
/* This file is part of the XP framework
 *
 * $Id$
 */

  uses(
    'util.cmd.Command',
    'io.Folder',
    'io.File',
    'io.FileUtil',
    'util.Date',
    'io.collections.FileCollection',
    'io.collections.iterate.FilteredIOCollectionIterator',
    'io.collections.iterate.ExtensionEqualsFilter',
    'util.log.Logger',
    'util.log.ConsoleAppender', 
    'de.thekid.dialog.Album',
    'de.thekid.dialog.Topic',
    'de.thekid.dialog.Update',
    'de.thekid.dialog.io.ImageProcessor',
    'de.thekid.dialog.io.IndexCreator',
    'de.thekid.dialog.GroupingStrategy',
    'img.filter.ConvolveFilter'
  );

  /**
   * Adds albums to dialog
   *
   * @purpose  Command
   */
  class AddAlbum extends Command {
    const
      DATA_FOLDER       = 'data/',
      IMAGE_FOLDER      = 'doc_root/albums/',
      HIGHLIGHTS_MAX    = 5,
      ENTRIES_PER_PAGE  = 5;
      
    protected
      $processor        = NULL,
      $albumStorage     = NULL,
      $groupingStrategy = NULL,
      $origin           = NULL,
      $album            = NULL,
      $destination      = NULL;

    /**
     * Constructor - initializes image processor.
     *
     */
    public function __construct() {
      $this->processor= new ImageProcessor();
      $this->processor->fullDimensions= array(800, 600);
      $this->processor->addFilter(new ConvolveFilter(
        new Kernel('[[-1, -1, -1], [-1, 16, -1], [-1, -1, -1]]'),
        8,
        0
      ));
    }

    /**
     * Normalize name to create a URL-friendly representation
     *
     * @param   string name
     * @return  string normalized
     */
    protected function normalizeName($name) {
      return preg_replace('/[^a-z0-9-]/i', '_', $name);
    }

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
     * Process meta data
     *
     * @param   de.thekid.dialog.AlbumImage image
     * @param   de.thekid.dialog.IEntry origin
     */
    protected function processMetaData(AlbumImage $image, IEntry $origin) {
    
      // Ensure image date is always present, fall back to origin's date
      // if necessary
      if (!$image->exifData->dateTime) {
        $image->exifData->dateTime= $origin->getDate();
      }

      // Extract topics form IPTC keywords if available
      if (!($iptc= $image->getIptcData())) return;
      
      foreach ($iptc->getKeywords() as $keyword) {
        $normalized= $this->normalizeName($keyword);
        if (!isset($this->topics[$normalized])) {
          $topic= new File(self::DATA_FOLDER.'topics/'.$normalized.'.dat');
          if ($topic->exists()) {
            $this->topics[$normalized]= unserialize(FileUtil::getContents($topic));
            $this->out->writeLine('     >> Found existing topic for ', $keyword);
          } else {
            $this->out->writeLine('     >> Creating new topic for ', $keyword);
            $this->topics[$normalized]= new Topic();
            $this->topics[$normalized]->setName($normalized);
            $this->topics[$normalized]->setTitle($keyword);
            $this->topics[$normalized]->setCreatedAt($origin->getDate());
          }
        }
        $this->topics[$normalized]->addImage($image, $origin->getName());
      }
    }
    
    /**
     * Main runner method
     *
     */
    public function run() {
    exit;
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
      for ($i= 0, $s= sizeof($images); $i < $s; $i++) {
        $key= $this->groupingStrategy->groupFor($images[$i]);
        if (!isset($chapter[$key])) {
          $chapter[$key]= $this->album->addChapter(new AlbumChapter($key));
        }

        $chapter[$key]->addImage($images[$i]);
      }
      
      // Save album and topics
      FileUtil::setContents($this->albumStorage, serialize($this->album));
      foreach ($this->topics as $normalized => $t) {
        FileUtil::setContents(new File(self::DATA_FOLDER.'topics/'.$normalized.'.dat'), serialize($t));
      }

      // Regenerate indexes
      $index= IndexCreator::forFolder(new Folder(self::DATA_FOLDER));
      $index->setEntriesPerPage(self::ENTRIES_PER_PAGE);
      $index->regenerate();

      // Generate topics
      for (
        $it= new FilteredIOCollectionIterator(new FileCollection(self::DATA_FOLDER.'topics'), new ExtensionEqualsFilter('.dat'));
        $it->hasNext();
      ) {
        $entry= basename($it->next()->getURI());
        $entries[$entry]= 'topics/'.basename($entry, '.dat');
      }
      ksort($entries);
      for ($i= 0, $s= sizeof($entries); $i < $s; $i+= self::ENTRIES_PER_PAGE) {
        FileUtil::setContents(
          new File(self::DATA_FOLDER.'topics_'.($i / self::ENTRIES_PER_PAGE).'.idx'), 
          serialize(array(
            'total'   => $s, 
            'perpage' => self::ENTRIES_PER_PAGE,
            'entries' => array_slice($entries, $i, self::ENTRIES_PER_PAGE)
          ))
        );
      }

      $this->out->writeLine('===> Finished at ', date('r'));
    }
  }
?>
