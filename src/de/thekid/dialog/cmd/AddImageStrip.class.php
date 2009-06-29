<?php
/* This file is part of the XP framework
 *
 * $Id$
 */

  uses(
    'de.thekid.dialog.cmd.ImportCommand',
    'de.thekid.dialog.GroupingStrategy',
    'de.thekid.dialog.ImageStrip'
  );

  /**
   * Adds image strips to dialog. Will import a complete directory of (original) 
   * images and assumes the following directory layout:
   * <pre>
   *   + [directory]
   *   |-- description.txt
   *   |-- image #1
   *   |-- image #2
   *   |-- ...
   * </pre>
   * 
   * It will then follow these rules:
   * 
   * <ul>
   *   <li>The images from the directory (file mask: *.JPG) will be taken
   *     for the images in this image strip. They will be resized to
   *     150 x 113 pixels for the overview and to 800 x 600 or 600 x 800
   *     pixels (depending on the picture's orientation) for the larger
   *     view.
   *
   *   </li><li>The entire text from the file description.txt will be used to
   *     make the text for the front page.
   *
   *   </li><li>The directory's name will be used for the image strips'
   *     title.Note: This can be overridden by the command line switch "-t"
   *
   *   </li><li>The oldest image's date will be used for the image strip's 
   *     creation timestamp.
   *     Note: This can be overridden by the command line switch "-c"
   *
   *   </li><li>The directory's name will be transformed to the image strip's online
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
  class AddImageStrip extends ImportCommand {
    protected
      $origin            = NULL,
      $destination       = NULL,
      $imageStripStorage = NULL,
      $imageStrip        = NULL,
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
     * Set image strip's title. If no title is given and the image strip did not 
     * previously exist, uses the origin folder's directory name.
     *
     * @param   string title default NULL
     */
    #[@arg]
    public function setTitle($title= NULL) {
      $this->title= $title;
    }

    /**
     * Set image strip's creation date. If no date is given and the image strip did not 
     * previously exist, uses the origin folder's creation date.
     *
     * @param   string date default NULL
     */
    #[@arg]
    public function setCreatedAt($date= NULL) {
      $this->createdAt= $date ? new Date($date) : NULL;
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
      
      // Normalize name
      $imageStripName= $this->normalizeName($this->origin->dirname);
      $this->out->writeLine('===> Adding image strip "', $imageStripName, '" from ', $this->origin);
      
      // Create destination folder if not already existant
      $this->destination= new Folder($this->imageFolder->getURI().$imageStripName);
      $this->processor->setOutputFolder($this->destination);
      
      // Check if the image strip already exists
      $this->imageStripStorage= new File($this->dataFolder, $imageStripName.'.dat');
      if ($this->imageStripStorage->exists()) {
        $this->out->writeLine('---> Found existing image strip');
        $this->imageStrip= unserialize(FileUtil::getContents($this->imageStripStorage));

        // Entries will be regenated from scratch    
        $this->imageStrip->images= array();
      } else {
        $this->out->writeLine('---> Creating new image strip');
        $this->imageStrip= new ImageStrip();
        $this->imageStrip->setName($imageStripName);
      }
      
      // If not specified: Read the title from title.txt if existant, use the 
      // directory name otherwise
      if (NULL !== $this->title) {
        $this->imageStrip->setTitle($this->title);
      } else {

        if (is_file($tf= $this->origin->getURI().'title.txt')) {
          $this->imageStrip->setTitle(file_get_contents($tf));
        } else {
          $this->imageStrip->setTitle($this->origin->dirname);
        }
      }
      $this->out->writeLine('---> Title "', $this->imageStrip->getTitle(), '"');

      // Read the introductory text from description.txt if existant
      if (is_file($df= $this->origin->getURI().'description.txt')) {
        $this->imageStrip->setDescription(file_get_contents($df));
      }
    
      // Create destination directory if not existant
      $this->destination->exists() || $this->destination->create(0755);
      
      // Process all images
      for (
        $images= array(),
        $it= new FilteredIOCollectionIterator(new FileCollection($this->origin->getURI()), $jpegs);
        $it->hasNext();
      ) {
        $image= $this->processor->albumImageFor($it->next()->getURI());
        $this->processMetaData($image, $this->imageStrip);

        $images[]= $image;
        $this->out->writeLine('     >> Added image ', $image->getName());
      }
      
      // Sort images by their creation date (from EXIF data)
      usort($images, create_function(
        '$a, $b', 
        'return $b->exifData->dateTime->compareTo($a->exifData->dateTime);'
      ));

      // Add images
      for ($i= 0, $s= sizeof($images); $i < $s; $i++) {
        $this->imageStrip->addImage($images[$i]);

        if ($images[$i]->exifData->dateTime && !$this->createdAt) {
          $this->out->writeLine('---> Inferring image strip creation date from ', $images[$i]);
          $this->createdAt= $images[$i]->exifData->dateTime;
        }
      }

      $this->imageStrip->setCreatedAt($this->createdAt);
      $this->out->writeLine('---> Created ', $this->imageStrip->getCreatedAt());
      
      // Save image strip and topics
      FileUtil::setContents($this->imageStripStorage, serialize($this->imageStrip));
    }
  }
?>
