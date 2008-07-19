<?php
/* This file is part of the XP framework
 *
 * $Id$
 */

  uses(
    'de.thekid.dialog.cmd.ImportCommand',
    'de.thekid.dialog.SingleShot',
    'de.thekid.dialog.io.ShotProcessor'
  );

  /**
   * Adds single shots ("Featured images") to dialog. Will import a 
   * single image file.
   *
   * Three views of the image are created:
   * <ol>
   *   <li>A detailed "wide-screen" view (approximately 16:9)</li>
   *   <li>A colored version</li>
   *   <li>A grayscale version</li>
   * </ol>
   *
   * They are rendered (in the default layout) as follows:
   * <pre>
   *   .------------------------..-----------.
   *   |                        ||   color   |
   *   |                        ||   thumb   |
   *   |       detailed         |'-----------'
   *   |        wide            |.-----------.
   *   |                        || grayscale |
   *   |                        ||   thumb   |
   *   '------------------------''-----------'
   * </pre>
   *
   * If a file with the same filename as the origin's but with ".txt" 
   * extension exists, its complete contents are used as a descriptive
   * text.
   *
   * Example: When adding IMG_6100.jpg as featured image, content from a
   * file by name IMG_6100.txt (in the same directory as the image) will 
   * be used as description.
   *
   * @purpose  Command
   */
  class AddSingleShot extends ImportCommand {
    protected
      $origin           = NULL,
      $destination      = NULL,
      $shotStorage      = NULL,
      $shot             = NULL;

    /**
     * Returns processor. Overrides base class getProcessor() method.
     *
     * @return  de.thekid.dialog.io.ImageProcessor
     */
    protected function getProcessor() {
      $processor= new ShotProcessor();
      $processor->detailDimensions= array(619, 347);
      return $processor;
    }

    /**
     * Set origin file
     *
     * @param   string file
     */
    #[@arg(position= 0)]
    public function setOrigin($file) {
      $this->origin= new File($file);
      if (!$this->origin->exists()) {
        throw new FileNotFoundException('File "'.$file.'" does not exist');
      }
      
      // Normalize name
      $fileName= substr($this->origin->getFilename(), 0, strpos($this->origin->getFilename(), '.'));
      $shotName= $this->normalizeName($fileName);
      $this->out->writeLine('===> Adding shot "', $shotName, '" from ', $this->origin);
      
      // Create destination folder if not already existant
      $this->destination= new Folder(self::SHOTS_FOLDER);
      $this->processor->setOutputFolder($this->destination);
      
      // Check if the shot already exists
      $this->shotStorage= new File(self::DATA_FOLDER.$shotName.'.dat');
      if ($this->shotStorage->exists()) {
        $this->out->writeLine('---> Found existing shot');
        $this->shot= unserialize(FileUtil::getContents($this->shotStorage));
      } else {
        $this->out->writeLine('---> Creating new shot');
        $this->shot= new SingleShot();
        $this->shot->setName($shotName);
        $this->shot->setFileName($this->origin->getFilename());
      }        

      // Read the introductory text from description.txt if existant
      if (is_file($df= $this->origin->getPath().DIRECTORY_SEPARATOR.$fileName.'.txt')) {
        $this->shot->setDescription(file_get_contents($df));
      }
    }
    
    /**
     * Set shots's title. If no title is given and the shot did not 
     * previously exist, uses the origin file's name.
     *
     * @param   string title default NULL
     */
    #[@arg]
    public function setTitle($title= NULL) {
      if (!$title && !$this->shot->getTitle()) {
        $this->shot->setTitle($this->origin->getFilename());
      } else {
        $this->shot->setTitle($title);
      }
      $this->out->writeLine('---> Title "', $this->shot->getTitle(), '"');
    }

    /**
     * Set shots's creation date. If no date is given and the shot did not 
     * previously exist, uses the origin file's creation date.
     *
     * @param   string date default NULL
     */
    #[@arg]
    public function setCreatedAt($date= NULL) {
      if (!$date && !$this->shot->getCreatedAt()) {
        $this->shot->setDate(new Date($this->origin->createdAt()));
      } else {
        $this->shot->setDate(new Date($date));
      }
      $this->out->writeLine('---> Created ', $this->shot->getDate());
    }
    
    /**
     * Import
     *
     */
    protected function doImport() {
      $image= $this->processor->albumImageFor($this->origin->getURI());
      $this->processMetaData($image, $this->shot);
      $this->shot->setImage($image);
      
      // Save shot
      FileUtil::setContents($this->shotStorage, serialize($this->shot));
    }
  }
?>
