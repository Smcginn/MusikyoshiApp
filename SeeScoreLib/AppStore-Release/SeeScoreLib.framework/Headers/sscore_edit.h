//
//  sscore_edit.h
//  SeeScoreLib
//
//  Copyright (c) 2015 Dolphin Computing Ltd. All rights reserved.
//
// No warranty is made as to the suitability of this for any purpose
//

#ifndef SeeScoreLib_sscore_edit_h
#define SeeScoreLib_sscore_edit_h

#include "sscore.h"
#include "sscore_contents.h"
#include "sscore_sym.h"

#ifdef __cplusplus
extern "C" {
#endif
	
	/*!
	 @header interface to editing the MusicXML
	 */
	
	#define sscore_edit_maxinserttextcharacters 64 // eg for direction words
	
	#define sscore_kMaxFontNameLength 64
	
	/*!
	 @enum sscore_edit_leftrightlocation_e
	 @abstract define horizontal location relative to another item
	 */
	enum sscore_edit_leftrightlocation_e { sscore_edit_lr_undefined, sscore_edit_left,sscore_edit_right };
		
	/*!
	 @enum sscore_edit_texttype_e
	 @abstract define type of direction words text
	 @discussion unfortunately there is currently no way for the MusicXML to capture this important information
	 (except directive) but we hope it will be added to the standard in future.
	 SeeScore internally uses various ad-hoc techniques including text matching with known strings to attempt to
	 identify the type automatically
	 */
	enum sscore_edit_texttype_e {
		/* undefined type */
		sscore_edit_tt_undefined,
		
		/* the direction is a directive placed at the left of the bar aligned with the time signature usually a tempo and/or metronome */
		sscore_edit_tt_directive,
		
		/* the direction is a dynamic eg mf, cresc., dim */
		sscore_edit_tt_dynamics,
		
		/* a tempo marking eg Allegro, rit. */
		sscore_edit_tt_tempo,
		
		/* an articulation marking eg pizz., arco */
		sscore_edit_tt_articulation,
		
		/* a repeat instruction eg DC, DS */
		sscore_edit_tt_repeat,
		
		/* a string number */
		sscore_edit_tt_string,
		
		/* special note text placed above all other markings identified to SeeScore by tagging with a trailing space character */
		sscore_edit_tt_note };

	/*!
	 @enum sscore_edit_basetype
	 @abstract a base type of element in the score
	 */
	enum sscore_edit_basetype {
		sscore_edit_invalid_basetype,
		sscore_edit_clef_basetype,
		sscore_edit_note_basetype,
		sscore_edit_rest_basetype,
		sscore_edit_notehead_basetype,
		sscore_edit_dots_basetype,
		sscore_edit_accidental_basetype,
		sscore_edit_lyric_basetype,
		sscore_edit_direction_basetype,
		sscore_edit_notation_basetype,
		sscore_edit_timesig_basetype,
		sscore_edit_keysig_basetype,
		sscore_edit_harmony_basetype,
		sscore_edit_numbasetypes
	};
	
	/*!
	 @enum sscore_edit_clef_type
	 @abstract a type of clef
	 */
	enum sscore_edit_clef_type {
		sscore_edit_clef_invalid,
		sscore_edit_clef_G,
		sscore_edit_clef_F,
		sscore_edit_clef_C,
		sscore_edit_clef_perc,
		sscore_edit_clef_tab };
	
	/*!
	 @enum sscore_edit_clef_shift
	 @abstract to specify a clef with an 8 above or below
	 */
	enum sscore_edit_clef_shift {
		sscore_edit_clef_shift_none,
		sscore_edit_clef_shift_octaveup,
		sscore_edit_clef_shift_octavedown };
	
	/*!
	 @enum sscore_edit_note_value
	 @abstract a note or rest value
	 */
	enum sscore_edit_note_value {
		sscore_edit_noteval_invalid,
		sscore_edit_noteval_breve,
		sscore_edit_noteval_whole,	// semibreve
		sscore_edit_noteval_half,		// minim
		sscore_edit_noteval_4th,		// crotchet
		sscore_edit_noteval_8th,		// quaver
		sscore_edit_noteval_16th,
		sscore_edit_noteval_32th,
		sscore_edit_noteval_64th,
		sscore_edit_noteval_128th};
	
	/*!
	 @enum sscore_edit_accidental_type
	 @abstract a type of accidental
	 */
	enum sscore_edit_accidental_type {
		sscore_edit_accidental_invalid,
		sscore_edit_accidental_doubleflat,
		sscore_edit_accidental_flat,
		sscore_edit_accidental_natural,
		sscore_edit_accidental_sharp,
		sscore_edit_accidental_doublesharp,
	};
	
	/*!
	 @enum sscore_edit_dynamic_type
	 @abstract a type of dynamic
	 */
	enum sscore_edit_dynamic_type {
		sscore_edit_dynamic_invalid,
		sscore_edit_dynamic_f,
		sscore_edit_dynamic_ff,
		sscore_edit_dynamic_fff,
		sscore_edit_dynamic_ffff,
		sscore_edit_dynamic_fffff,
		sscore_edit_dynamic_ffffff,
		sscore_edit_dynamic_p,
		sscore_edit_dynamic_pp,
		sscore_edit_dynamic_ppp,
		sscore_edit_dynamic_pppp,
		sscore_edit_dynamic_ppppp,
		sscore_edit_dynamic_pppppp,
		sscore_edit_dynamic_mf,
		sscore_edit_dynamic_mp,
		sscore_edit_dynamic_sf,
		sscore_edit_dynamic_sfp,
		sscore_edit_dynamic_sfpp,
		sscore_edit_dynamic_fp,
		sscore_edit_dynamic_rf,
		sscore_edit_dynamic_rfz,
		sscore_edit_dynamic_sfz,
		sscore_edit_dynamic_sffz,
		sscore_edit_dynamic_fz,
		sscore_edit_dynamic_other
	};
	
	enum sscore_edit_direction_type {
		sscore_edit_direction_rehearsal,
		sscore_edit_direction_segno,
		sscore_edit_direction_words,
		sscore_edit_direction_coda,
		sscore_edit_direction_wedge,
		sscore_edit_direction_dynamics,
		sscore_edit_direction_dashes,
		sscore_edit_direction_bracket,
		sscore_edit_direction_pedal,
		sscore_edit_direction_metronome,
		sscore_edit_direction_octave_shift,
		sscore_edit_direction_harp_pedals,
		sscore_edit_direction_damp,
		sscore_edit_direction_damp_all,
		sscore_edit_direction_eyeglasses,
		sscore_edit_direction_string_mute,
		sscore_edit_direction_scordatura,
		sscore_edit_direction_image,
		sscore_edit_direction_principal_voice,
		sscore_edit_direction_accordion_registration,
		sscore_edit_direction_percussion,
		sscore_edit_direction_other_direction_e
	};
	
	enum sscore_edit_notation_type {
		sscore_edit_notation_invalid,
		sscore_edit_notation_tied,
		sscore_edit_notation_slur,
		sscore_edit_notation_tuplet,
		sscore_edit_notation_glissando,
		sscore_edit_notation_slide,
		sscore_edit_notation_ornaments,
		sscore_edit_notation_technical,
		sscore_edit_notation_articulations,
		sscore_edit_notation_dynamics,
		sscore_edit_notation_fermata,
		sscore_edit_notation_arpeggiate,
		sscore_edit_notation_non_arpeggiate,
		sscore_edit_notation_accidental_mark,
		sscore_edit_notation_other
	};
	
	/*!
	 @enum sscore_edit_articulation_type
	 @abstract a type of articulation
	 */
	enum sscore_edit_articulation_type {
		sscore_edit_articulation_invalid,
		sscore_edit_articulation_staccato,
		sscore_edit_articulation_staccatissimo,
		sscore_edit_articulation_tenuto,
		sscore_edit_articulation_spiccato,
		sscore_edit_articulation_accent,
		sscore_edit_articulation_strong_accent,
		sscore_edit_articulation_detached_legato,
		sscore_edit_articulation_scoop,
		sscore_edit_articulation_plop,
		sscore_edit_articulation_doit,
		sscore_edit_articulation_falloff,
		sscore_edit_articulation_breath_mark,
		sscore_edit_articulation_caesura,
		sscore_edit_articulation_stress,
		sscore_edit_articulation_unstress,
		sscore_edit_articulation_other
	};
	
	/*!
	 @enum sscore_edit_technical_type
	 @abstract a MusicXML technical type
	 */
	enum sscore_edit_technical_type {
		sscore_edit_technical_invalid,
		sscore_edit_technical_up_bow,
		sscore_edit_technical_down_bow,
		sscore_edit_technical_harmonic,
		sscore_edit_technical_open_string,
		sscore_edit_technical_thumb_position,
		sscore_edit_technical_fingering,
		sscore_edit_technical_pluck,
		sscore_edit_technical_double_tongue,
		sscore_edit_technical_triple_tongue,
		sscore_edit_technical_stopped,
		sscore_edit_technical_snap_pizzicato,
		sscore_edit_technical_fret,
		sscore_edit_technical_string,
		sscore_edit_technical_hammer_on,
		sscore_edit_technical_pull_off,
		sscore_edit_technical_bend,
		sscore_edit_technical_tap,
		sscore_edit_technical_heel,
		sscore_edit_technical_toe,
		sscore_edit_technical_fingernails,
		sscore_edit_technical_hole,
		sscore_edit_technical_arrow,
		sscore_edit_technical_handbell,
		sscore_edit_technical_other
	};
	
	/*!
	 @enum sscore_edit_ornament_type
	 @abstract a type of ornament
	 */
	enum sscore_edit_ornament_type {
		sscore_edit_ornament_invalid,
		sscore_edit_ornament_trill_mark,
		sscore_edit_ornament_turn,
		sscore_edit_ornament_delayed_turn,
		sscore_edit_ornament_inverted_turn,
		sscore_edit_ornament_delayed_inverted_turn,
		sscore_edit_ornament_vertical_turn,
		sscore_edit_ornament_shake,
		sscore_edit_ornament_wavy_line,
		sscore_edit_ornament_mordent,
		sscore_edit_ornament_inverted_mordent,
		sscore_edit_ornament_schleifer,
		sscore_edit_ornament_tremolo,
		sscore_edit_ornament_other
	};
	
	/*!
	 @enum sscore_edit_timesig_type
	 @abstract a type of time signature
	 */
	enum sscore_edit_timesig_type {
		sscore_edit_timesig_invalid,
		sscore_edit_timesig_common,
		sscore_edit_timesig_cut,
		sscore_edit_timesig_normal
	};
	
	/*!
	 @enum sscore_edit_wedge_type
	 @abstract type of wedge
	 */
	enum sscore_edit_wedge_type {
		sscore_edit_wedge_dim,
		sscore_edit_wedge_cresc,
		sscore_edit_wedge_stop
	};
	
	/*!
	 @enum sscore_edit_slur_type
	 @abstract direction of slur or tie
	 */
	enum sscore_edit_slur_type {
		sscore_edit_slur_over,
		sscore_edit_slur_under
	};

	/*!
	 @struct sscore_edit_type
	 @abstract encapsulates a specific type of item which can be edited in the score - eg a treble clef or a crotchet, or an up-bow notation
	 @discussion contains sscore_edit_basetype (accessed with sscore_edit_basetypefor) and specific type info
	 This should be passed between calls - no need to access internal state
	 */
	typedef struct sscore_edit_type
	{// private
		unsigned u[16];
	} sscore_edit_type;
	
	/*!
	 @struct sscore_edit_insertinfo
	 @abstract information about an item to insert into the score
	 @discussion the fields are private to SeeScore
	 */
	typedef struct sscore_edit_insertinfo
	{
		//private:
		unsigned u[128];
	} sscore_edit_insertinfo;
	
	/*!
	 @struct sscore_edit_targetlocation
	 @abstract information about a location relative to existing notes in the bar of where to insert an item into the score
	 @discussion this contains information identifying the part,bar,staff and nearest note(s)
	 The fields are private to SeeScore
	 */
	typedef struct sscore_edit_targetlocation
	{
		//private:
		unsigned u[64];
	} sscore_edit_targetlocation;

	/*!
	 @struct sscore_edit_deleteinfo
	 @abstract information about an item to delete from the score
	 @discussion the fields are private to SeeScore
	 */
	typedef struct sscore_edit_deleteinfo
	{
		//private
		sscore_edit_type type;
		int partIndex;
		int barIndex;
		sscore_item_handle item_h;
		unsigned u[128];
	} sscore_edit_deleteinfo;
	
	/*!
	 @struct sscore_edit_detailinfo
	 @abstract detailed information about an object to be inserted
	 @discussion the fields are private to SeeScore
	 */
	typedef struct sscore_edit_detailinfo
	{
		//private
		unsigned u[128];
	}sscore_edit_detailinfo;
	
	/*!
	 @struct sscore_edit_fontinfo
	 @abstract font information
	 */
	typedef struct sscore_edit_fontinfo
	{
		char family[sscore_kMaxFontNameLength]; // normally blank - SeeScore does not heed font names when rendering
		bool bold;
		bool italic;
		float pointSize; // 0 for default
		unsigned u[8];
	} sscore_edit_fontinfo;

	/*!
	 @struct sscore_state_container
	 @abstract a wrapper for the complete state of the score at any particular point
	 @discussion each edit creates a new state. undo and redo work by accessing states from a list of historic states
	 SeeScore uses a Persistent Data Structure see https://en.wikipedia.org/wiki/Persistent_data_structure
	 sscore_edit_barchanged can be used to compare states for any particular bar to enable the app to suppress redraw for unchanged bars
	 */
	typedef struct sscore_state_container sscore_state_container;
	
	/*!
	 @enum sscore_state_changereason_e
	 @abstract a reason for a state change passed to sscore_changehandler
	 */
	enum sscore_state_changereason_e { sscore_state_changereason_undo, sscore_state_changereason_redo, sscore_state_changereason_newstate};
	
	/*!
	 @typedef sscore_changehandler
	 @abstract a handler which is notified of a state change
	 @param prevstate the previous state
	 @param newstate the new state
	 @param reason the reason for the state change
	 @param arg context argument
	 */
	typedef void (*sscore_changehandler)(sscore_state_container *prevstate,
										sscore_state_container *newstate,
										enum sscore_state_changereason_e reason,
										void *arg);
	
	/*!
	 @typedef sscore_changehandler_id
	 @abstract a handle for a change handler returned from sscore_edit_addchangehandler
	 */
	typedef unsigned long sscore_changehandler_id;
	
	
	/*!
	 @function sscore_edit_typeforclef
	 @abstract get a sscore_edit_type for a particular clef
	 @param type the clef subtype
	 @param line the staff line [1..5], 0 for default
	 @param shift octave shift
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforclef(enum sscore_edit_clef_type type, int line, enum sscore_edit_clef_shift shift);
	
	/*!
	 @function sscore_edit_typefortimesig
	 @abstract get a sscore_edit_type for a time signature
	 @param type the type of time signature
	 @param upper the upper number if applicable
	 @param lower the lower number if applicable
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefortimesig(enum sscore_edit_timesig_type type, int upper, int lower);
	
	/*!
	 @function sscore_edit_typeforkeysig
	 @abstract get a sscore_edit_type for a particular key signature
	 @param fifths if positive the number of sharps in the key, if negative the number of flats in the key
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforkeysig(int fifths);
	
	/*!
	 @function sscore_edit_typefornote
	 @abstract get a sscore_edit_type for a particular note
	 @param type the note value
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefornote(enum sscore_edit_note_value type);
	
	/*!
	 @function sscore_edit_typeforrest
	 @abstract get a sscore_edit_type for a particular rest
	 @param type the rest value
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforrest(enum sscore_edit_note_value type);
	
	/*!
	 @function sscore_edit_typeforaccidental
	 @abstract get a sscore_edit_type for a particular accidental
	 @param type the accidental subtype
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforaccidental(enum sscore_edit_accidental_type type);
	
	/*!
	 @function sscore_edit_typefordynamicsnotation
	 @abstract get a sscore_edit_type for a particular dynamic (as a MusicXML notation)
	 @param type the dynamic subtype
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefordynamicsnotation(enum sscore_edit_dynamic_type type);

	/*!
	 @function sscore_edit_typefordynamicsdirection
	 @abstract get a sscore_edit_type for a particular dynamic (as a MusicXML direction)
	 @param type the dynamic subtype
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefordynamicsdirection(enum sscore_edit_dynamic_type type);
	
	/*!
	 @function sscore_edit_typefordirectionwords
	 @abstract get a sscore_edit_type for direction.direction-type.words
	 @param textType define the function of the text in the score
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefordirectionwords(enum sscore_edit_texttype_e textType);
	
	/*!
	 @function sscore_edit_typeformetronome
	 @abstract get a sscore_edit_type for direction.direction-type.metronome
	 @param beat_type conventional value for the note type (4 = crotchet/quarter, 2 = minim/half etc)
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeformetronome(int beat_type);
	
	/*!
	 @function sscore_edit_typeforarticulation
	 @abstract get a sscore_edit_type for a particular articulation
	 @param type the articulation subtype
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforarticulation(enum sscore_edit_articulation_type type);
	
	/*!
	 @function sscore_edit_typefortechnical
	 @abstract get a sscore_edit_type for a particular technical type
	 @param type the technical subtype
	 @param info any extra info (max 8 bytes) required for type eg finger number for fingering
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefortechnical(enum sscore_edit_technical_type type, const char *info);
	
	/*!
	 @function sscore_edit_typeforornament
	 @abstract get a sscore_edit_type for a particular ornament
	 @param type the ornament subtype
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforornament(enum sscore_edit_ornament_type type);
	
	/*!
	 @function sscore_edit_typefordots
	 @abstract get a sscore_edit_type for dots (ie on dotted note)
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefordots();
	
	/*!
	 @function sscore_edit_typeforpedal
	 @abstract get a sscore_edit_type for a pedal
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforpedal();
	
	/*!
	 @function sscore_edit_typefortuplet
	 @abstract get a sscore_edit_type for a tuplet
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefortuplet();
	
	/*!
	 @function sscore_edit_typeforarpeggiate
	 @abstract get a sscore_edit_type for an arpeggiate
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforarpeggiate();

	/*!
	 @function sscore_edit_typeforoctaveshift
	 @abstract get a sscore_edit_type for an octave shift
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforoctaveshift();

	/*!
	 @function sscore_edit_typeforfermata
	 @abstract get a sscore_edit_type for a fermata
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforfermata();

	/*!
	 @function sscore_edit_typeforwedge
	 @abstract get a sscore_edit_type for a wedge ('hairpin')
	 @param tp cresc or dim
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforwedge(enum sscore_edit_wedge_type tp);

	/*!
	 @function sscore_edit_typeforslur
	 @abstract get a sscore_edit_type for a slur
	 @param tp above or below
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typeforslur(enum sscore_edit_slur_type tp);
	
	/*!
	 @function sscore_edit_typefortied
	 @abstract get a sscore_edit_type for a tied type
	 @param tp above or below
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefortied(enum sscore_edit_slur_type tp);

	/*!
	 @function sscore_edit_typefor
	 @abstract get a sscore_edit_type for a basetype which requires no other distinction
	 @param btype the base type
	 @return the type info
	 */
	EXPORT sscore_edit_type sscore_edit_typefor(enum sscore_edit_basetype btype);
	
	/*!
	 @function sscore_edit_invalidtype
	 @abstract get an invalid sscore_edit_type
	 @discussion compare this with a return value to test if invalid
	 @return invalid sscore_edit_type
	 */
	EXPORT sscore_edit_type sscore_edit_invalidtype();
	
	/*!
	 @function sscore_edit_typeisvalid
	 @abstract test type is valid
	 @return false if this type is invalid
	 */
	EXPORT bool sscore_edit_typeisvalid(const sscore_edit_type *type);

	/*!
	 @function sscore_edit_basetypefor
	 @abstract get the sscore_edit_basetype for sscore_edit_type
	 @param tp type
	 @return base type
	 */
	EXPORT enum sscore_edit_basetype sscore_edit_basetypefor(const sscore_edit_type *tp);
	
	/*!
	 @function sscore_edit_internalsubtypefor
	 @abstract internal use
	 @param tp type
	 @return subtype
	 */
	EXPORT unsigned sscore_edit_internalsubtypefor(const sscore_edit_type *tp);
	
	/*!
	 @function sscore_edit_internalintparamfor
	 @abstract internal use
	 @param tp type
	 @param index
	 @return int param
	 */
	EXPORT int sscore_edit_internalintparamfor(const sscore_edit_type *tp, int index);
	
	/*!
	 @function sscore_edit_internalstrparamfor
	 @abstract internal use
	 @param tp type
	 @param buffer
	 @param buffersize
	 @return number of bytes copied to buffer
	 */
	EXPORT int sscore_edit_internalstrparamfor(const sscore_edit_type *tp, char *buffer, int buffersize);
	
	/*!
	 @function sscore_edit_symbolfor
	 @abstract get the sscore_symbol for a type
	 @param tp the type
	 @return the symbol for the given type
	 */
	EXPORT sscore_symbol sscore_edit_symbolfor(const sscore_edit_type *tp);
	
	/*!
	 @function sscore_edit_addchangehandler
	 @abstract add a changehandler to be called when the score changes as a result of editing
	 @param sc the score
	 @param handler the change handler
	 @param arg the context argument to be passed to the handler when it is called
	 @return an id to be used as an argument to sscore_edit_removechangehandler
	 */
	EXPORT sscore_changehandler_id sscore_edit_addchangehandler(sscore *sc, sscore_changehandler handler, void *arg);
	
	/*!
	 @function sscore_edit_removechangehandler
	 @abstract remove a changehandler added with sscore_edit_addchangehandler
	 @param sc the score
	 @param handler_id the handler id returned from sscore_edit_addchangehandler
	 */
	EXPORT void sscore_edit_removechangehandler(sscore *sc, sscore_changehandler_id handler_id);
	
	/*!
	 @function sscore_edit_hasundo
	 @abstract is the current state undoable? (used to enable undo button in UI)
	 @param sc the score
	 @return true if the state is undoable
	 */
	EXPORT bool sscore_edit_hasundo(sscore *sc);
	
	/*!
	 @function sscore_edit_undo
	 @abstract undo the last operation (if undoable)
	 @param sc the score
	 */
	EXPORT void sscore_edit_undo(sscore *sc);
	
	/*!
	 @function sscore_edit_hasredo
	 @abstract is the current state redoable? (used to enable redo button in UI)
	 @param sc the score
	 @return true if the state is redoable
	 */
	EXPORT bool sscore_edit_hasredo(sscore *sc);
	
	/*!
	 @function sscore_edit_redo
	 @abstract redo the last undone operation (if possible)
	 @param sc the score
	 */
	EXPORT void sscore_edit_redo(sscore *sc);
	
	/*!
	 @function sscore_edit_getdeleteinfo
	 @abstract get info for deleting an item or notation
	 @param sys the system
	 @param comp the component to delete
	 */
	EXPORT sscore_edit_deleteinfo sscore_edit_getdeleteinfo(const sscore_system *sys, const sscore_component *comp);
	
	/*!
	 @function sscore_edit_getdirectiondeleteinfo
	 @abstract get info for deleting a direction-type from a direction
	 @param sys the system
	 @param dirtype the direction-type to delete
	 */
	EXPORT sscore_edit_deleteinfo sscore_edit_getdirectiondeleteinfo(const sscore_system *sys, const sscore_con_directiontype *dirtype);
	
	/*!
	 @function sscore_edit_nearesttargetlocation
	 @abstract get a target location near to pos to insert an item of type itemType
	 @param system the system
	 @param itemType the type of object to insert
	 @param pos the position defining the target location
	 @param max_distance the furthest distance to accept the target
	 @return the target location nearest to pos which can receive the item of type itemType
	 */
	EXPORT sscore_edit_targetlocation sscore_edit_nearesttargetlocation(const sscore_system *system,
																		const sscore_edit_type *itemType,
																		const sscore_point *pos,
																		float max_distance);
	
	/*!
	 @function sscore_edit_targetlocationfornotecomponent
	 @abstract get a target location at a particular note
	 @param system the system
	 @param notecomponent a component identifying a note
	 @return the target location aligned with the note
	 */
	EXPORT sscore_edit_targetlocation sscore_edit_targetlocationfornotecomponent(const sscore_system *system,
																				 const sscore_component *notecomponent);
	
	/*!
	 @function sscore_edit_targetlocationisvalidforinsert
	 @abstract is the target location valid to insert the item type?
	 @param score the score
	 @param system the system
	 @param itemType the type of object to insert
	 @param target the target to test
	 @return true if the target location is valid
	 */
	EXPORT bool sscore_edit_targetlocationisvalidforinsert(const sscore *score,
														   const sscore_system *system,
														   const sscore_edit_type *itemType,
														   const sscore_edit_targetlocation *target);
	
	/*!
	 @function sscore_edit_targetlocationpartindex
	 @abstract is the target location valid?
	 @param target the target to test
	 @return the part index for the target
	 */
	EXPORT int sscore_edit_targetlocationpartindex(const sscore_edit_targetlocation *target);
	
	/*!
	 @function sscore_edit_targetlocationbarindex
	 @param target the target to test
	 @return the bar index for the target
	 */
	EXPORT int sscore_edit_targetlocationbarindex(const sscore_edit_targetlocation *target);

	/*!
	 @function sscore_edit_targetlocationcoord
	 @abstract return the (approximate) position for inserting the itemType at the target location in the system
	 @param system the system
	 @param itemType the type of the item
	 @param target from sscore_edit_nearesttargetlocation()
	 @return coordinates for the target
	 */
	EXPORT sscore_point sscore_edit_targetlocationcoord(const sscore_system *system,
														const sscore_edit_type *itemType,
														const sscore_edit_targetlocation *target);

	/*!
	 @function sscore_edit_system_drawdragitem
	 @abstract draw any required decoration - (ledgers) for the item being dragged in the system
	 @param graphics the graphics context
	 @param sys the system
	 @param itemType
	 @param p
	 */
	EXPORT void sscore_edit_system_drawdragitem(sscore_graphics *graphics,
												const sscore_system *sys,
												const sscore_edit_type *itemType,
												const sscore_point *p);
	
	/*!
	 @function sscore_edit_getinsertinfo
	 @abstract create sscore_edit_insertinfo to pass to sscore_edit_insertitem to insert a new item in the score
	 @param score the score
	 @param type the sscore_edit_type to insert, returned from sscore_edit_typefor...
	 @param detailinfo detailed info about the object, use NULL for now
	 @return the sscore_edit_insertinfo to pass to sscore_edit_insertitem
	 */
	EXPORT sscore_edit_insertinfo sscore_edit_getinsertinfo(const sscore *score,
															const sscore_edit_type *type,
															const sscore_edit_detailinfo *detailinfo);
	
	/*!
	 @function sscore_edit_insertitemtype
	 @abstract return item type from the sscore_edit_insertinfo
	 @param info the sscore_edit_insertinfo form sscore_edit_getinsertinfo
	 @return the sscore_edit_type of the item
	 */
	EXPORT sscore_edit_type sscore_edit_insertitemtype(const sscore_edit_insertinfo *info);

	/*!
	 @function sscore_edit_gettextdetailinfo
	 @abstract load sscore_edit_detailinfo with font information
	 @param name a font name (ignored by SeeScore display), can be NULL to leave unspecified
	 @param bold true for bold text
	 @param italic true for italic text
	 @return sscore_edit_detailinfo to pass to sscore_edit_gettextinsertinfo
	 */
	EXPORT sscore_edit_detailinfo sscore_edit_gettextdetailinfo(const char *name, bool bold, bool italic);
	
	/*!
	 @function sscore_edit_gettextinsertinfo
	 @abstract create sscore_edit_insertinfo to pass to sscore_edit_insertitem for direction.direction-type.words
	 @param score the score
	 @param note the component for the note above/below which the text will be displayed
	 @param vloc if above place the text above the staff. If below place the text below the note
	 @param text_utf8 text for new direction words element
	 @param textType the type of text.
	 @param fontinfo specifies the font information - NULL to use default font style based on textType
	 @return the sscore_edit_insertinfo to pass to sscore_edit_insertitem
	 */
	EXPORT sscore_edit_insertinfo sscore_edit_gettextinsertinfo(const sscore *score,
																const sscore_component *note,
																enum sscore_system_stafflocation_e vloc,
																const char *text_utf8,
																enum sscore_edit_texttype_e textType,
																const sscore_edit_fontinfo *fontinfo); // NULLABLE
	
	/*!
	 @function sscore_edit_direction_modifywords
	 @abstract modify existing text (direction-type words)
	 @param score the score
	 @param directionType the direction-type element containing the words to edit
	 @param text_utf8 the text to insert - NULL to leave unchanged
	 @param fontinfo font parameters - NULL to leave unchanged
	 @return true if succeeded
	 */
	EXPORT bool sscore_edit_direction_modifywords(sscore *score,
												  const sscore_con_directiontype *directionType,
												  const char *text_utf8, // NULLABLE
												  const sscore_edit_fontinfo *fontinfo); // NULLABLE

	/*!
	 @function sscore_edit_direction_words_getfontinfo
	 @abstract
	 @param score the score
	 @param directionType the direction-type element containing the words
	 @return font info
	 */
	EXPORT sscore_edit_fontinfo sscore_edit_direction_words_getfontinfo(sscore *score, const sscore_con_directiontype *directionType);
	
	/*!
	 @function sscore_edit_insertitem
	 @abstract attempt to insert the item in the score
	 @param score the score
	 @param item info about the item to insert
	 @param target info about the logical position in the score where it should be inserted
	 @return true if success
	 */
	EXPORT bool sscore_edit_insertitem(sscore *score, const sscore_edit_insertinfo *item, const sscore_edit_targetlocation *target);
	
	/*!
	 @function sscore_edit_insertmultiitem
	 @abstract attempt to insert a left/right item in the score (eg slur, tied, wedge, tuplet etc)
	 @param score the score
	 @param item info about the item to insert
	 @param target_left info about the logical position in the score where the left side of the item should be placed
	 @param target_right info about the logical position in the score where the right side of the item should be placed
	 @return true if success
	 */
	EXPORT bool sscore_edit_insertmultiitem(sscore *score,
											const sscore_edit_insertinfo *item,
											const sscore_edit_targetlocation *target_left,
											const sscore_edit_targetlocation *target_right);
	
	/*!
	 @function sscore_edit_deleteitem
	 @abstract remove an item from the score
	 @param sc the score
	 @param item info about the item to delete from sscore_edit_getdeleteinfo
	 @return true if succeeded, or false with nothing changed if the item was not found
	 */
	EXPORT bool sscore_edit_deleteitem(sscore *sc, const sscore_edit_deleteinfo *item);
	
	/*!
	 @function sscore_edit_setdotcount
	 @abstract set the number of dots (0,1,2) for the note or rest
	 @param sc the score
	 @param partIndex the part index [0..]
	 @param barIndex the bar index [0..]
	 @param item_h the item handle
	 @param numdots the number of dots for the note or rest
	 @return true if succeeded, or false with nothing changed if the item was not found or it already has numdots dots
	 */
	EXPORT bool sscore_edit_setdotcount(sscore *sc, int partIndex, int barIndex, sscore_item_handle item_h, int numdots);
	
	/*!
	 @function sscore_edit_selectitem
	 @abstract select (highlight) an item in the system
	 @param system the system
	 @param item_h the item handle
	 @param partIndex the part index [0..]
	 @param barIndex the bar index [0..]
	 @param fgCol the foreground colour to use to paint the selected item
	 @param bgCol the background colour for the selected item
	 */
	EXPORT void sscore_edit_selectitem(sscore_system *system, sscore_item_handle item_h,
									   int partIndex, int barIndex,
									   const sscore_colour_alpha *fgCol, const sscore_colour_alpha *bgCol);
	
	/*!
	 @function sscore_edit_deselectitem
	 @abstract deselect a selected item
	 @param system the system
	 @param item_h the item handle
	 */
	EXPORT void sscore_edit_deselectitem(sscore_system *system, sscore_item_handle item_h);
	
	/*!
	 @function sscore_edit_deselectall
	 @abstract deselect all selected items in system
	 @param system the system
	 */
	EXPORT void sscore_edit_deselectall(sscore_system *system);

	/*!
	 @function sscore_edit_barchanged
	 @abstract true if anything has changed in the given bar between prevstate and newstate
	 @param barIndex the bar index [0..]
	 @param prevstate the previous state from sscore_changehandler
	 @param newstate the new state from sscore_changehandler
	 @return true if anything has changed in the given bar
	 */
	EXPORT bool sscore_edit_barchanged(int barIndex,
									   const sscore_state_container *prevstate,
									   const sscore_state_container *newstate);
	
	/*!
	 @function sscore_edit_updatelayout
	 @abstract update the layout after state change
	 @param graphics the graphics for measurement
	 @param score the score
	 @param newstate the new state, argument to sscore_changehandler
	 */
	EXPORT void sscore_edit_updatelayout(sscore_graphics *graphics, sscore *score, const sscore_state_container *newstate);
	
#ifdef __cplusplus
}
#endif

#endif