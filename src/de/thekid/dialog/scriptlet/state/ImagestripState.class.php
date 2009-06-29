<?php
/* This class is part of the XP framework
 *
 * $Id$
 */

  uses('de.thekid.dialog.scriptlet.AbstractDialogState');

  /**
   * Handles /xml/imagestrip
   *
   * @purpose  State
   */
  class ImageStripState extends AbstractDialogState {

    /**
     * Process this state.
     *
     * @param   scriptlet.xml.workflow.WorkflowScriptletRequest request
     * @param   scriptlet.xml.XMLScriptletResponse response
     * @param   scriptlet.xml.workflow.Context context
     */
    public function process($request, $response, $context) {
      $name= $request->getQueryString();

      if ($imageStrip= $this->getEntryFor($name)) {
        $child= $response->addFormResult(new Node('imagestrip', NULL, array(
          'name'         => $imageStrip->getName(),
          'title'        => $imageStrip->getTitle(),
          'num_images'   => $imageStrip->numImages(),
          'page'         => $this->getDisplayPageFor($name)
        )));
        $child->addChild(new Node('description', new PCData($imageStrip->getDescription())));
        $child->addChild(Node::fromObject($imageStrip->createdAt, 'created'));
        $child->addChild(Node::fromArray($imageStrip->images, 'images'));
      }
    }
  }
?>
