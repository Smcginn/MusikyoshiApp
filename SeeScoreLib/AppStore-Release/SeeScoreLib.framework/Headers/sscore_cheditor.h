//
//  sscore_cheditor.h
//  SeeScoreLib
//
//  Created by James Sutton on 23/11/2015.
//  Copyright © 2015 Dolphin Computing Ltd. All rights reserved.
//

#ifndef sscore_cheditor_h
#define sscore_cheditor_h

#ifdef __cplusplus
extern "C" {
#endif

/***** The chord editor *****
 *
 * Displays a staff with the chord to edit
 */

/*!
 @struct sscore_cheditor
 @abstract abstract chord editor
 */
typedef struct sscore_cheditor sscore_cheditor;

/*!
 @typedef sscore_cheditor_noteid
 @abstract unique identifier for a notehead in a chord
 @discussion this is unchanged on reordering the noteheads
 */
typedef unsigned long sscore_cheditor_noteid;

#define sscore_cheditor_invalid_id 0

/*!
 @enum sscore_cheditor_accidental_type
 @abstract types of accidental
 */
enum sscore_cheditor_accidental_type { sscore_cheditor_noaccidental, sscore_cheditor_doubleflat, sscore_cheditor_flat, sscore_cheditor_natural, sscore_cheditor_sharp, sscore_cheditor_doublesharp};

/*!
 @function sscore_cheditor_create
 @abstract create the score editor which displays an item to be edited on a staff
 @discussion the caller must install a change handler which forces a redraw of the chord editor on any state change
 @param sc the score
 @param graphics the sscore_graphics returned from sscore_graphics_create
 is used to measure bounds of items, particularly text.
 @param magnification the scale of the staff
 @param frame the size of the frame containing the view
 @param partIndex the part index containing the item to edit
 @param barIndex the bar index containing the item to edit
 @param item_h the unique id of the item
 */
EXPORT sscore_cheditor *sscore_cheditor_create(sscore *score, sscore_graphics *graphics, float magnification, const sscore_rect *frame, int partIndex, int barIndex, sscore_item_handle item_h);

/*!
 @function sscore_cheditor_dispose
 @abstract dispose all memory associated with scedit
 @discussion cannot call any functions in this interface with scedit after calling sscore_cheditor_dispose
 @param scedit the score editor returned from sscore_edit_create_editor
 */
EXPORT void sscore_cheditor_dispose(sscore_cheditor *scedit);

/*!
 @function sscore_cheditor_size
 @abstract return size of score editor
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the graphics
 */
EXPORT sscore_size sscore_cheditor_size(const sscore_cheditor *scedit, sscore_graphics *graphics);

/*!
 @function sscore_cheditor_draw
 @abstract draw the score editor
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 */
EXPORT void sscore_cheditor_draw(sscore_cheditor *scedit, sscore_graphics *graphics);

/*!
 @function sscore_cheditor_notehead_id_at
 @abstract get the index of the nearest notehead to p in a displayed chord
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param p a point in the score editor
 @param maxdist the maximum distance from the point to the centre of the closest notehead in tenths of a staff space
 @return the index of the nearest notehead in the chord - 0 is the top note or the only note. Increases downwards in the chord
 sscore_cheditor_invalid_id if p is further than maxdist from the closest notehead
 */
EXPORT sscore_cheditor_noteid sscore_cheditor_notehead_id_at(sscore_cheditor *scedit, sscore_graphics *graphics, const sscore_point *p, float maxdist);

/*!
 @function sscore_cheditor_pitch_alter_for_notehead
 @abstract -1 if notehead is flattened, +1 if sharpened
 @param scedit the score editor returned from sscore_edit_create_editor
 @param noteheadId the id of the notehead in the chord
 @return -2,-1 if the notehead is flat, 0 if natural, +1,+2 if sharp
 */
EXPORT int sscore_cheditor_pitch_alter_for_notehead(sscore_cheditor *scedit, sscore_cheditor_noteid noteheadId);

/*!
 @function sscore_cheditor_notehead_bb
 @abstract the bounding box of a notehead in the chord
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 @return the bounding box of the notehead
 */
EXPORT sscore_rect sscore_cheditor_notehead_bb(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId);

/*!
 @function sscore_cheditor_cancel_op
 @abstract cancel current operation (drag,accidental,remove,add)
 @param scedit the score editor returned from sscore_edit_create_editor
 */
EXPORT void sscore_cheditor_cancel_op(sscore_cheditor *scedit);

/*!
 @function sscore_cheditor_drag
 @abstract actively drag a notehead up or down on the staff
 @discussion this is called repeatedly while dragging and the notehead will be drawn in the new position in sscore_edit_draw.
 The notehead will appear to slide up and down the stem with the drag, stopping at the correct space and line positions
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 @param translation the translation of the drag (ie translation->y = 0 for no displacement)
 */
EXPORT void sscore_cheditor_drag(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId, const sscore_point *translation);

/*!
 @function sscore_cheditor_end_drag
 @abstract called at the end of a drag operation to update the score with the newly pitched note
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 @param translation the translation of the drag (ie translation->y = 0 for no displacement)
 */
EXPORT void sscore_cheditor_end_drag(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId, const sscore_point *translation);

/*!
 @function sscore_cheditor_accidental_for_chord_note
 @abstract get the accidental for the note
 @param scedit the score editor returned from sscore_edit_create_editor
 @param noteheadId the id of the notehead in the chord
 @param accidental_pitch_alter the amount by which to alter the note pitch
 */
EXPORT enum sscore_cheditor_accidental_type sscore_cheditor_accidental_for_chord_note(sscore_cheditor *scedit, sscore_cheditor_noteid noteheadId, int accidental_pitch_alter);

/*!
 @function sscore_cheditor_show_accidental
 @abstract show the note pitch alteration in the score editor with the correct accidental (grey if it will not actually be displayed at this location in the score)
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 @param accidental_pitch_alter -2,-1 for flat, 0 for natural, +1,+2 for sharp
 */
EXPORT void sscore_cheditor_show_accidental(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId, int accidental_pitch_alter);

/*!
 @function sscore_edit_set_accidental
 @abstract set the note pitch alteration in the score (an accidental is displayed if appropriate at the score location)
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 @param accidental_pitch_alter -2,-1 for flat, 0 for natural, +1,+2 for sharp
 */
EXPORT void sscore_cheditor_set_accidental(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId, int accidental_pitch_alter);

/*!
 @function sscore_cheditor_show_remove_chord_note
 @abstract update the chord editor to show the note missing from the chord
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 */
EXPORT void sscore_cheditor_show_remove_chord_note(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId);

/*!
 @function sscore_cheditor_remove_chord_note
 @abstract remove a note from a chord in the score NB we cannot remove the last - ie there must be one remaining
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param noteheadId the id of the notehead in the chord
 */
EXPORT void sscore_cheditor_remove_chord_note(sscore_cheditor *scedit, sscore_graphics *graphics, sscore_cheditor_noteid noteheadId);

/*!
 @function sscore_cheditor_show_add_chord_note
 @abstract display a new notehead in the chord at the correct point nearest to p
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param p the position nearest which we should place the notehead in the displayed chord
 */
EXPORT void sscore_cheditor_show_add_chord_note(sscore_cheditor *scedit, sscore_graphics *graphics, const sscore_point *p);

/*!
 @function sscore_cheditor_add_chord_note
 @abstract actually add a new note to the chord in the score
 @param scedit the score editor returned from sscore_edit_create_editor
 @param graphics the sscore_graphics returned from sscore_graphics_create
 @param p the position nearest which the notehead should be placed in the chord
 */
EXPORT void sscore_cheditor_add_chord_note(sscore_cheditor *scedit, sscore_graphics *graphics, const sscore_point *p);

#ifdef __cplusplus
}
#endif

#endif /* sscore_cheditor_h */
