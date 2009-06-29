<?php
/* This class is part of the XP framework
 *
 * $Id$
 */

  uses(
    'util.Date',
    'de.thekid.dialog.AlbumImage',
    'de.thekid.dialog.IEntry'
  );

  /**
   * Represents an image strip
   *
   * @see      xp://de.thekid.dialog.Album
   * @purpose  Value object
   */
  class ImageStrip extends Object implements IEntry {
    public
      $name         = '',
      $title        = '',
      $createdAt    = NULL,
      $description  = '',
      $images       = array();

    /**
     * Constructor
     *
     * @param   string name
     */
    public function __construct($name) {
      $this->name= $name;
    }

    /**
     * Set name
     *
     * @param   string name
     */
    public function setName($name) {
      $this->name= $name;
    }

    /**
     * Get name
     *
     * @return  string
     */
    public function getName() {
      return $this->name;
    }

    /**
     * Set Title
     *
     * @param   string title
     */
    public function setTitle($title) {
      $this->title= $title;
    }

    /**
     * Get Title
     *
     * @return  string
     */
    public function getTitle() {
      return $this->title;
    }

    /**
     * Set CreatedAt
     *
     * @param   util.Date createdAt
     */
    public function setCreatedAt($createdAt) {
      $this->createdAt= $createdAt;
    }

    /**
     * Get CreatedAt
     *
     * @return  util.Date
     */
    public function getCreatedAt() {
      return $this->createdAt;
    }
    
    /**
     * Get date
     *
     * @see     xp://de.thekid.dialog.IEntry
     * @return  util.Date
     */
    public function getDate() {
      return $this->createdAt;
    }

    /**
     * Set Description
     *
     * @param   string description
     */
    public function setDescription($description) {
      $this->description= $description;
    }

    /**
     * Get Description
     *
     * @return  string
     */
    public function getDescription() {
      return $this->description;
    }

    /**
     * Add an element to images
     *
     * @param   de.thekid.dialog.AlbumImage image
     */
    public function addImage($image) {
      $this->images[]= $image;
    }

    /**
     * Get one image element by position. Returns NULL if the element 
     * can not be found.
     *
     * @param   int i
     * @return  de.thekid.dialog.AlbumImage
     */
    public function imageAt($i) {
      if (!isset($this->images[$i])) return NULL;
      return $this->images[$i];
    }

    /**
     * Get number of images
     *
     * @return  int
     */
    public function numImages() {
      return sizeof($this->images);
    }
    
    /**
     * Retrieve a string representation
     *
     * @return  string
     */
    public function toString() {
      $is= '';
      for ($i= 0, $s= sizeof($this->images); $i < $s; $i++) {
        $is.= '    '.str_replace("\n", "\n  ", $this->images[$i]->toString())."\n";
      }
      return sprintf(
        "%s(%s) {\n%s  }",
        $this->getClassName(),
        $this->name,
        $is
      );
    }
  }
?>
