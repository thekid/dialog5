<?php
/* This class is part of the XP framework
 *
 * $Id$ 
 */

  uses('lang.Enum');

  /**
   * Grouping strategy enumeration
   *
   * @purpose  Enumeration
   */
  abstract class GroupingStrategy extends Enum {
    public static
      $hour, $day;

    static function __static() {
      self::$hour= newinstance(__CLASS__, array(0, 'hour'), '{
        static function __static() { }
        public function groupFor(AlbumImage $image) {
          return $image->exifData->dateTime->toString("Y-m-d H");
        }
      }');
      self::$day= newinstance(__CLASS__, array(0, 'day'), '{
        static function __static() { }
        public function groupFor(AlbumImage $image) {
          return $image->exifData->dateTime->toString("Y-m-d");
        }
      }');
    } 

    /**
     * Returns all enum members
     *
     * @return  lang.Enum[]
     */
    public static function values() {
      return parent::membersOf(__CLASS__);
    }
    
    /**
     * Returns group for a given album image.
     *
     * @param   de.thekid.dialog.AlbumImage
     * @return  string unique group identifier
     */
    public abstract function groupFor(AlbumImage $image);

  }
?>
