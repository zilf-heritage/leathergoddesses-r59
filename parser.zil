"PARSER for
		      LEATHER GODDESSES OF PHOBOS
	(c) Copyright 1986 Infocom, Inc.  All Rights Reserved."

;"Parser global variable convention:  All parser globals will begin
with 'P-'. Local variables are not restricted in any way." 

<SETG SIBREAKS ".,\"">

<GLOBAL P-AND <>> 

<GLOBAL PRSA <>>

<GLOBAL PRSI <>>

<GLOBAL PRSO <>>

<GLOBAL P-TABLE 0>  

<GLOBAL P-ONEOBJ 0> 

<GLOBAL P-SYNTAX 0> 

<GLOBAL P-CCTBL <TABLE 0 0 0>>  

;"pointers used by CLAUSE-COPY (source/destination beginning/end pointers)"
<CONSTANT CC-SBPTR 0>
<CONSTANT CC-SEPTR 1>
<CONSTANT CC-OCLAUSE 2>

<GLOBAL P-LEN 0>

<GLOBAL WINNER 0>

<GLOBAL P-LEXV <ITABLE 60 (LEXV) 0 <BYTE 0> <BYTE 0>>>
<GLOBAL AGAIN-LEXV <ITABLE 60 (LEXV) 0 <BYTE 0> <BYTE 0>>>
<GLOBAL RESERVE-LEXV <ITABLE 60 (LEXV) 0 <BYTE 0> <BYTE 0>>>

<GLOBAL RESERVE-PTR <>>

<CONSTANT P-INBUF-LENGTH 120> ;"number of bytes in input buffer"
<GLOBAL P-INBUF <ITABLE 120 (BYTE LENGTH) 0>> ;"INBUF - Input buffer for READ"
<GLOBAL RESERVE-INBUF <ITABLE 120 (BYTE LENGTH) 0>> ; "FIX #36"
<GLOBAL OOPS-INBUF <ITABLE 120 (BYTE LENGTH) 0>>

<GLOBAL OOPS-TABLE <TABLE <> <> <> <>>>
<CONSTANT O-PTR 0>
<CONSTANT O-START 1>
<CONSTANT O-LENGTH 2>
<CONSTANT O-END 3>

<GLOBAL P-CONT <>> ;"Parse-cont variable"  

<GLOBAL P-IT-OBJECT <>>

<GLOBAL P-HIM-OBJECT <>>

<GLOBAL P-HER-OBJECT <>>

<ROUTINE THIS-IS-IT (OBJ)
	 <COND (<OR <NOT .OBJ>
		    <AND <VERB? WALK>
			 <PRSO? .OBJ>> ;"PRSO is a direction"
		    <EQUAL? .OBJ ,PROTAGONIST> ;"is this necessary?"
		    <EQUAL? .OBJ ,NOT-HERE-OBJECT ,ME ,GLOBAL-ROOM>>
		<RTRUE>)  
	       (<FSET? .OBJ ,FEMALEBIT>
		<SETG P-HER-OBJECT .OBJ>)
	       (<FSET? .OBJ ,ACTORBIT>
		<SETG P-HIM-OBJECT .OBJ>)
	       (T
		<SETG P-IT-OBJECT .OBJ>)>>

<GLOBAL LAST-PSEUDO-LOC <>>

<GLOBAL P-OFLAG <>> ;"Orphan flag" 

<GLOBAL P-MERGED <>>

<GLOBAL P-ACLAUSE <>>

<GLOBAL P-ANAM <>>  

<GLOBAL P-AADJ <>>

;"Parser variables and temporaries"

<CONSTANT P-LEXWORDS 1> ;"Byte offset to # of entries in LEXV"
<CONSTANT P-LEXSTART 1> ;"Word offset to start of LEXV entries"
<CONSTANT P-LEXELEN 2> ;"Number of words per LEXV entry"
<CONSTANT P-WORDLEN 4>
<CONSTANT P-PSOFF 4> ;"Offset to parts of speech byte"
<CONSTANT P-P1OFF 5> ;"Offset to first part of speech"
<CONSTANT P-P1BITS 3> ;"First part of speech bit mask in PSOFF byte"
<CONSTANT P-ITBLLEN 9>

<GLOBAL P-ITBL
	<TABLE 0 0 0 0 0 0 0 0 0 0>>  

<GLOBAL P-OTBL
	<TABLE 0 0 0 0 0 0 0 0 0 0>>  

<GLOBAL P-VTBL
	<TABLE 0 #BYTE 0 #BYTE 0>>

<GLOBAL P-OVTBL
	<TABLE 0 #BYTE 0 #BYTE 0>>

<GLOBAL P-NCN 0>

<CONSTANT P-VERB 0>
<CONSTANT P-VERBN 1>
<CONSTANT P-PREP1 2>
<CONSTANT P-PREP1N 3>
<CONSTANT P-PREP2 4>
<CONSTANT P-NC1 6>
<CONSTANT P-NC1L 7>
<CONSTANT P-NC2 8>
<CONSTANT P-NC2L 9>

<GLOBAL QUOTE-FLAG <>>

;<GLOBAL P-INPUT-WORDS <>>

<GLOBAL P-END-ON-PREP <>>

<GLOBAL P-PRSA-WORD <>>

" Grovel down the input finding the verb, prepositions, and noun clauses.
   If the input is <direction> or <walk> <direction>, fall out immediately
   setting PRSA to ,V?WALK and PRSO to <direction>.  Otherwise, perform
   all required orphaning, syntax checking, and noun clause lookup."

<ROUTINE PARSER ("AUX" (PTR ,P-LEXSTART) WRD (VAL 0) (VERB <>) ;(DONT <>)
		      OMERGED OWINNER OLEN LEN (DIR <>) (NW 0) (LW 0) (CNT -1))
	<REPEAT ()
		<COND (<G? <SET CNT <+ .CNT 1>> ,P-ITBLLEN> <RETURN>)
		      (T
		       <COND (<NOT ,P-OFLAG>
			      <PUT ,P-OTBL .CNT <GET ,P-ITBL .CNT>>)>
		       <PUT ,P-ITBL .CNT 0>)>>
	<SET OMERGED ,P-MERGED>
	<SET OWINNER ,WINNER>
	;<PUT ,P-NAMW 0 <>>
	;<PUT ,P-NAMW 1 <>>
	;<PUT ,P-ADJW 0 <>>
	;<PUT ,P-ADJW 1 <>>
	<SETG P-ADVERB <>>
	<SETG P-MERGED <>>
	<SETG P-END-ON-PREP <>>
	<PUT ,P-PRSO ,P-MATCHLEN 0>
	<PUT ,P-PRSI ,P-MATCHLEN 0>
	<PUT ,P-BUTS ,P-MATCHLEN 0>
	<COND (<AND <NOT ,QUOTE-FLAG>
		    <N==? ,WINNER ,PROTAGONIST>>
	       <SETG WINNER ,PROTAGONIST>
	       <COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>>
		      <SETG HERE <LOC ,WINNER>>)>
	       <SETG LIT <LIT? ,HERE>>)>
	<COND (,RESERVE-PTR
	       <SET PTR ,RESERVE-PTR>
	       <STUFF ,P-LEXV ,RESERVE-LEXV>
	       <INBUF-STUFF ,P-INBUF ,RESERVE-INBUF> ;"rfix no. 36"
	       <COND (<AND <NOT <EQUAL? ,VERBOSITY 0>>
			   <EQUAL? ,PROTAGONIST ,WINNER>>
		      <CRLF>)>
	       <SETG RESERVE-PTR <>>
	       <SETG P-CONT <>>)
	      (,P-CONT
	       <SET PTR ,P-CONT>
	       <COND (<AND <NOT <EQUAL? ,VERBOSITY 0>>
			   <EQUAL? ,PROTAGONIST ,WINNER>>
		      <CRLF>)>
	       <SETG P-CONT <>>)
	      (T
	       <SETG WINNER ,PROTAGONIST>
	       <SETG QUOTE-FLAG <>>
	       <COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>>
		      <SETG HERE <LOC ,WINNER>>)>
	       <SETG LIT <LIT? ,HERE>>
	       <COND (<NOT <EQUAL? ,VERBOSITY 0>>
		      <CRLF>)>
	       <TELL ">">
	       <READ ,P-INBUF ,P-LEXV>
	       <SET OLEN <GETB ,P-LEXV ,P-LEXWORDS>>)>
	<SETG P-LEN <GETB ,P-LEXV ,P-LEXWORDS>>
	<COND (<ZERO? ,P-LEN>
	       <TELL "[Come again?]" CR>
	       <RFALSE>)
	      (<EQUAL? <GET ,P-LEXV .PTR> ,W?OOPS>
	       <COND (<EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>> ;"rfix 36"
			      ,W?PERIOD ,W?COMMA>
		      <SET PTR <+ .PTR ,P-LEXELEN>>
		      <SETG P-LEN <- ,P-LEN 1>>)>
	       <COND (<NOT <G? ,P-LEN 1>>
		      <CANT-USE-THAT-WAY "OOPS">
		      <RFALSE>)
		     (<GET ,OOPS-TABLE ,O-PTR>
		      <COND (<G? ,P-LEN 2>
			     <TELL
"[Warning: Only the first word after OOPS is used.]" CR>)>
			   <PUT ,AGAIN-LEXV <GET ,OOPS-TABLE ,O-PTR>
			   <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>
		      <SETG WINNER .OWINNER> ;"Fixes OOPS w/char"
		      <INBUF-ADD <GETB ,P-LEXV <+ <* .PTR ,P-LEXELEN> 6>>
				 <GETB ,P-LEXV <+ <* .PTR ,P-LEXELEN> 7>>
				 <+ <* <GET ,OOPS-TABLE ,O-PTR> ,P-LEXELEN> 3>>
		      <STUFF ,P-LEXV ,AGAIN-LEXV>
		      <SETG P-LEN <GETB ,P-LEXV ,P-LEXWORDS>>;"Will this help?"
		      <SET PTR <GET ,OOPS-TABLE ,O-START>>
		      <INBUF-STUFF ,P-INBUF ,OOPS-INBUF>)
		     (T
		      <PUT ,OOPS-TABLE ,O-END <>>
		      <TELL "[There was no word to replace!]" CR>
		      <RFALSE>)>)
	      (T <PUT ,OOPS-TABLE ,O-END <>>)>
	<COND (<EQUAL? <GET ,P-LEXV .PTR> ,W?AGAIN ,W?G>
	       <COND (,P-OFLAG
		      <CANT-USE-THAT-WAY "AGAIN">
		      <RFALSE>)
		     (<NOT ,P-WON>
		      <TELL "[That would just repeat a mistake!]" CR>
		      <RFALSE>)
		     (<AND <NOT <EQUAL? .OWINNER ,PROTAGONIST>>
			   <NOT <VISIBLE? .OWINNER>>>
		      <TELL "[" ,YOU-CANT "see " D .OWINNER " any more.]" CR>
		      <RFALSE>)
		     (<G? ,P-LEN 1>
		      <COND (<OR <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
					,W?PERIOD ,W?COMMA ,W?THEN>
				 <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
					,W?AND>>
			     <SET PTR <+ .PTR <* 2 ,P-LEXELEN>>>
			     <PUTB ,P-LEXV ,P-LEXWORDS
				   <- <GETB ,P-LEXV ,P-LEXWORDS> 2>>)
			    (T
			     <RECOGNIZE>
			     <RFALSE>)>)
		     (T
		      <SET PTR <+ .PTR ,P-LEXELEN>>
		      <PUTB ,P-LEXV ,P-LEXWORDS 
			    <- <GETB ,P-LEXV ,P-LEXWORDS> 1>>)>
	       <COND (<G? <GETB ,P-LEXV ,P-LEXWORDS> 0>
		      <STUFF ,RESERVE-LEXV ,P-LEXV>
		      <INBUF-STUFF ,RESERVE-INBUF ,P-INBUF>
		      <SETG RESERVE-PTR .PTR>)
		     (T
		      <SETG RESERVE-PTR <>>)>
	       ;<SETG P-LEN <GETB ,AGAIN-LEXV ,P-LEXWORDS>>
	       <SETG WINNER .OWINNER>
	       <SETG P-MERGED .OMERGED>
	       <INBUF-STUFF ,P-INBUF ,OOPS-INBUF>
	       <STUFF ,P-LEXV ,AGAIN-LEXV>
	       <SET CNT -1>
	       <SET DIR ,AGAIN-DIR>
	       <REPEAT ()
		<COND (<IGRTR? CNT ,P-ITBLLEN> <RETURN>)
		      (T <PUT ,P-ITBL .CNT <GET ,P-OTBL .CNT>>)>>)
	      (T
	       <STUFF ,AGAIN-LEXV ,P-LEXV>
	       <INBUF-STUFF ,OOPS-INBUF ,P-INBUF>
	       <PUT ,OOPS-TABLE ,O-START .PTR>
	       <PUT ,OOPS-TABLE ,O-LENGTH <* 4 ,P-LEN>> ;"fix #36"
	       <SET LEN
		    <* 2 <+ .PTR <* ,P-LEXELEN <GETB ,P-LEXV ,P-LEXWORDS>>>>>
	       <PUT ,OOPS-TABLE ,O-END <+ <GETB ,P-LEXV <- .LEN 1>>
					  <GETB ,P-LEXV <- .LEN 2>>>>
	       <SETG RESERVE-PTR <>>
	       <SET LEN ,P-LEN>
	       ;<SETG P-DIR <>>
	       <SETG P-NCN 0>
	       <SETG P-GETFLAGS 0>
	       <REPEAT ()
		<COND (<L? <SETG P-LEN <- ,P-LEN 1>> 0>
		       <SETG QUOTE-FLAG <>>
		       <RETURN>)
		      (<NAUGHTY-WORD? <SET WRD <GET ,P-LEXV .PTR>>>
		       <RFALSE>)
		      (<OR <SET WRD <GET ,P-LEXV .PTR>>
			   <SET WRD <NUMBER? .PTR>>>
		       <SET NW <NEXT-WORD .PTR>>
		       <COND (<AND <EQUAL? .WRD ,W?TO>
				   <EQUAL? .VERB ,ACT?TELL ,ACT?ASK>
				   ;"next clause added 8/20/84 by JW to
				     enable TELL MY NAME TO BEAST"
				   <WT? .NW ,PS?VERB ,P1?VERB>>
			      <PUT ,P-ITBL ,P-VERB ,ACT?TELL>
			      <SET WRD ,W?QUOTE>)
			     (<AND <EQUAL? .WRD ,W?THEN>
				   <G? ,P-LEN 0>
				   <NOT .VERB>
				   <NOT ,QUOTE-FLAG>>
			      <PUT ,P-ITBL ,P-VERB ,ACT?TELL>
			      <PUT ,P-ITBL ,P-VERBN 0>
			      <SET WRD ,W?QUOTE>)
			     ;(<AND <EQUAL? .WRD ,W?PERIOD>
				   <EQUAL? .LW ,W?MR>>
			      <SETG P-NCN <- ,P-NCN 1>>
			      <CHANGE-LEXV .PTR .LW T>
			      <SET WRD .LW>
			      <SET LW 0>)>
		       <COND (<OR <EQUAL? .WRD ,W?THEN ,W?PERIOD>
				  <EQUAL? .WRD ,W?QUOTE>> 
			      <COND (<EQUAL? .WRD ,W?QUOTE>
				     <COND (,QUOTE-FLAG
					    <SETG QUOTE-FLAG <>>)
					   (T
					    <SETG QUOTE-FLAG T>)>)>
			      <OR <ZERO? ,P-LEN>
				  <SETG P-CONT <+ .PTR ,P-LEXELEN>>>
			      <PUTB ,P-LEXV ,P-LEXWORDS ,P-LEN>
			      <RETURN>)
			     (<AND <SET VAL
					<WT? .WRD ,PS?DIRECTION ,P1?DIRECTION>>
				   <EQUAL? .VERB <> ,ACT?WALK ,ACT?GO>
				   <OR <EQUAL? .LEN 1>
				       <AND <EQUAL? .LEN 2>
					    <EQUAL? .VERB ,ACT?WALK ,ACT?GO
						     ;,ACT?FLY>>
				       <AND <EQUAL? .NW
						    ,W?THEN ,W?PERIOD ,W?QUOTE>
					    <NOT <L? .LEN 2>>>
				       <AND ,QUOTE-FLAG
					    <EQUAL? .LEN 2>
					    <EQUAL? .NW ,W?QUOTE>>
				       <AND <G? .LEN 2>
					    <EQUAL? .NW ,W?COMMA ,W?AND>>>>
			      <SET DIR .VAL>
			      <COND (<EQUAL? .NW ,W?COMMA ,W?AND>
				     <CHANGE-LEXV <+ .PTR ,P-LEXELEN>
					  ,W?THEN>)>
			      <COND (<NOT <G? .LEN 2>>
				     <SETG QUOTE-FLAG <>>
				     <RETURN>)>)
			     (<AND <SET VAL <WT? .WRD ,PS?VERB ,P1?VERB>>
				   <NOT .VERB>>
			      <SETG P-PRSA-WORD .WRD>
			      <SET VERB .VAL>
			      <PUT ,P-ITBL ,P-VERB .VAL>
			      <PUT ,P-ITBL ,P-VERBN ,P-VTBL>
			      <PUT ,P-VTBL 0 .WRD>
			      <PUTB ,P-VTBL 2 <GETB ,P-LEXV
						    <SET CNT
							 <+ <* .PTR 2> 2>>>>
			      <PUTB ,P-VTBL 3 <GETB ,P-LEXV <+ .CNT 1>>>)
			     (<OR <SET VAL <WT? .WRD ,PS?PREPOSITION 0>>
				  <AND <OR <EQUAL? .WRD ,W?ALL ,W?ONE ,W?BOTH>
					   <EQUAL? .WRD ,W?EVERYT>
					   <WT? .WRD ,PS?ADJECTIVE>
					   <WT? .WRD ,PS?OBJECT>>
				       <SET VAL 0>>>
			      <COND (<AND .VAL
					  <EQUAL? .WRD ,W?BACK>
					  <NOT <EQUAL? .VERB ,ACT?HAND>>>
				     <SET VAL 0>)>
			         ;"3/3/86 -- fix OPEN BACK DOOR given that
				   back is also a prep for HAND BACK OBJ -pdl"
			      <COND (<AND <G? ,P-LEN 0>
				      <EQUAL? .NW ,W?OF>
				      <ZERO? .VAL>
				      <NOT <EQUAL? .WRD ,W?ALL ,W?ONE ,W?A>>
				      <NOT <EQUAL? .WRD ,W?BOTH ,W?EVERYT>>>)
				    (<AND <NOT <ZERO? .VAL>>
				          <OR <ZERO? ,P-LEN>
					      <EQUAL? .NW ,W?THEN ,W?PERIOD>>>
				     <SETG P-END-ON-PREP T>
				     <COND (<L? ,P-NCN 2>
					    <PUT ,P-ITBL ,P-PREP1 .VAL>
					    <PUT ,P-ITBL ,P-PREP1N .WRD>)>)
				    (<EQUAL? ,P-NCN 2>
				     <TELL
"[There were too many nouns in that sentence.]" CR>
				     <RFALSE>)
				    (T
				     <SETG P-NCN <+ ,P-NCN 1>>
				     <OR <SET PTR <CLAUSE .PTR .VAL .WRD>>
					 <RFALSE>>
				     <COND (<L? .PTR 0>
					    <SETG QUOTE-FLAG <>>
					    <RETURN>)>)>)
			     ;(<AND <NOT .VERB>
				   <EQUAL? .WRD ,W?DON\'T ,W?DONT>>
			      <SET DONT T>)
			     (<WT? .WRD ,PS?BUZZ-WORD>)
			     (<AND <EQUAL? .VERB ,ACT?TELL>
				   <WT? .WRD ,PS?VERB ,P1?VERB>
				   ;"Next expr added to fix FORD, TELL ME WHY"
				   <EQUAL? ,WINNER ,PROTAGONIST>>
			      <SEE-MANUAL "talk to characters.">
			      <RFALSE>)
			     (T
			      <CANT-USE .PTR>
			      <RFALSE>)>)
		      (T
		       <UNKNOWN-WORD .PTR>
		       <RFALSE>)>
		<SET LW .WRD>
		<SET PTR <+ .PTR ,P-LEXELEN>>>)>
	<PUT ,OOPS-TABLE ,O-PTR <>>
	<COND (.DIR
	       <SETG PRSA ,V?WALK>
	       <SETG PRSO .DIR>
	       <SETG P-OFLAG <>>
	       <SETG P-WALK-DIR .DIR>
	       <SETG AGAIN-DIR .DIR>
	       ;<SETG DONT-FLAG .DONT>
	       <RETURN T>)>
	<SETG P-WALK-DIR <>>
	<SETG AGAIN-DIR <>>
	<COND ;(<OR <NOT ,P-OFLAG>
	       	   <NOT <ORPHAN-MERGE>>>
	       <SETG DONT-FLAG .DONT>)
	      (,P-OFLAG
	       <ORPHAN-MERGE>)>
	<COND (<AND <SYNTAX-CHECK>
		    <SNARF-OBJECTS>
		    <MANY-CHECK>
		    <TAKE-CHECK>>
	       T)>>

;<ROUTINE CHANGE-LEXV (PTR WRD)
	 <PUT ,P-LEXV .PTR .WRD>
	 <PUT ,AGAIN-LEXV .PTR .WRD>>

<ROUTINE CHANGE-LEXV (PTR WRD "OPTIONAL" (PTRS? <>) "AUX" X Y Z)
	 <COND (.PTRS?
		<SET X <+ 2 <* 2 <- .PTR ,P-LEXELEN>>>>
		<SET Y <GETB ,P-LEXV .X>>
		<SET Z <+ 2 <* 2 .PTR>>>
		<PUTB     ,P-LEXV .Z .Y>
		<PUTB ,AGAIN-LEXV .Z .Y>
		<SET Y <GETB ,P-LEXV <+ 1 .X>>>
		<SET Z <+ 3 <* 2 .PTR>>>
		<PUTB     ,P-LEXV .Z .Y>
		<PUTB ,AGAIN-LEXV .Z .Y>)>
	 <PUT ,P-LEXV .PTR .WRD>
	 <PUT ,AGAIN-LEXV .PTR .WRD>>

;<GLOBAL DONT-FLAG <>>

<GLOBAL P-WALK-DIR <>>

<GLOBAL AGAIN-DIR <>>

<GLOBAL P-DIRECTION <>>

;"For AGAIN purposes, put contents of one LEXV table into another."
<ROUTINE STUFF (DEST SRC "OPTIONAL" (MAX 29) "AUX" (PTR ,P-LEXSTART) (CTR 1)
						   BPTR)
	 <PUTB .DEST 0 <GETB .SRC 0>>
	 <PUTB .DEST 1 <GETB .SRC 1>>
	 <REPEAT ()
	  <PUT .DEST .PTR <GET .SRC .PTR>>
	  <SET BPTR <+ <* .PTR 2> 2>>
	  <PUTB .DEST .BPTR <GETB .SRC .BPTR>>
	  <SET BPTR <+ <* .PTR 2> 3>>
	  <PUTB .DEST .BPTR <GETB .SRC .BPTR>>
	  <SET PTR <+ .PTR ,P-LEXELEN>>
	  <COND (<IGRTR? CTR .MAX>
		 <RETURN>)>>>

;"Put contents of one INBUF into another"
<ROUTINE INBUF-STUFF (DEST SRC "AUX" (CNT -1))
	 <REPEAT ()
	  <COND (<IGRTR? CNT ,P-INBUF-LENGTH> <RETURN>)
		(T <PUTB .DEST .CNT <GETB .SRC .CNT>>)>>> 

;"Put the word in the positions specified from P-INBUF to the end of
OOPS-INBUF, leaving the appropriate pointers in AGAIN-LEXV"
<ROUTINE INBUF-ADD (LEN BEG SLOT "AUX" DBEG (CTR 0) TMP)
	 <COND (<SET TMP <GET ,OOPS-TABLE ,O-END>>
		<SET DBEG .TMP>)
	       (T
		<SET DBEG <+ <GETB ,AGAIN-LEXV
				   <SET TMP <GET ,OOPS-TABLE ,O-LENGTH>>>
			     <GETB ,AGAIN-LEXV <+ .TMP 1>>>>)>
	 <PUT ,OOPS-TABLE ,O-END <+ .DBEG .LEN>>
	 <REPEAT ()
	  <PUTB ,OOPS-INBUF <+ .DBEG .CTR> <GETB ,P-INBUF <+ .BEG .CTR>>>
	  <SET CTR <+ .CTR 1>>
	  <COND (<EQUAL? .CTR .LEN> <RETURN>)>>
	 <PUTB ,AGAIN-LEXV .SLOT .DBEG>
	 <PUTB ,AGAIN-LEXV <- .SLOT 1> .LEN>>

;"WT? checks whether word pointed at by PTR is the correct part of speech.
   The second argument is the part of speech (,PS?<part of speech>). The
   3rd argument (,P1?<part of speech>), if given, causes the value
   for that part of speech to be returned."

;<ROUTINE WT? (PTR BIT "OPTIONAL" (B1 5) "AUX" (OFFS ,P-P1OFF) TYP)
	<COND (<BTST <SET TYP <GETB .PTR ,P-PSOFF>> .BIT>
	       <COND (<G? .B1 4> <RTRUE>)
		     (T
		      <SET TYP <BAND .TYP ,P-P1BITS>>
		      <COND (<NOT <EQUAL? .TYP .B1>> <SET OFFS <+ .OFFS 1>>)>
		      <GETB .PTR .OFFS>)>)>>

<ROUTINE WT? (PTR BIT "OPTIONAL" (B1 5) "AUX" (OFFS ,P-P1OFF) TYP)
	 ;"this version of WT? allows three parts of speech"
	<COND (<BTST <SET TYP <GETB .PTR ,P-PSOFF>> .BIT>
	       <COND (<G? .B1 4>
		      <RTRUE>)
		     (<EQUAL? .BIT ,PS?OBJECT>
		      1)
		     (T
		      <SET TYP <BAND .TYP ,P-P1BITS>>
		      <COND (<NOT <EQUAL? .TYP .B1>>
			     <SET OFFS <+ .OFFS 1>>)>
		      <GETB .PTR .OFFS>)>)>>

<ROUTINE NEXT-WORD (PTR "AUX" NW)
	 <COND (<NOT <ZERO? ,P-LEN>>
	        <COND (<SET NW <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>
		       .NW)
		      (ELSE
		       <NUMBER? <+ .PTR ,P-LEXELEN>>)>)>>

;" Scan through a noun clause, leave a pointer to its starting location"
<ROUTINE CLAUSE (PTR VAL WRD "AUX" OFF NUM (ANDFLG <>) (FIRST?? T) NW (LW 0))
	<SET OFF <* <- ,P-NCN 1> 2>>
	<COND (<NOT <EQUAL? .VAL 0>>
	       <PUT ,P-ITBL <SET NUM <+ ,P-PREP1 .OFF>> .VAL>
	       <PUT ,P-ITBL <+ .NUM 1> .WRD>
	       <SET PTR <+ .PTR ,P-LEXELEN>>)
	      (T <SETG P-LEN <+ ,P-LEN 1>>)>
	<COND (<ZERO? ,P-LEN> <SETG P-NCN <- ,P-NCN 1>> <RETURN -1>)>
	<PUT ,P-ITBL <SET NUM <+ ,P-NC1 .OFF>> <REST ,P-LEXV <* .PTR 2>>>
	<REPEAT ()
		<COND (<L? <SETG P-LEN <- ,P-LEN 1>> 0>
		       <PUT ,P-ITBL <+ .NUM 1> <REST ,P-LEXV <* .PTR 2>>>
		       <RETURN -1>)>
		<SET WRD <GET ,P-LEXV .PTR>>
		<COND (<NAUGHTY-WORD? .WRD>
		       <RFALSE>)
		      (<OR .WRD <SET WRD <NUMBER? .PTR>>>
		       <SET NW <NEXT-WORD .PTR>>
		       <COND (<AND .FIRST?? ;"fix 'lie down on...'"
				   <OR <EQUAL? .WRD ,W?THE ,W?A ,W?AN>
				       <AND .VAL
					    <WT? .WRD ,PS?PREPOSITION>
					    <NOT <WT? .WRD ,PS?ADJECTIVE>>
					     ;"fix 'knock on back door',
					       break compiler">>>
			      <PUT ,P-ITBL .NUM <REST <GET ,P-ITBL .NUM> 4>>)
			     ;(<AND <EQUAL? .WRD ,W?PERIOD>
				   <EQUAL? .LW ,W?MR>>
			      <SET LW 0>)
			     (<EQUAL? .WRD ,W?AND ,W?COMMA>
			      <SET ANDFLG T>)
			     (<OR <EQUAL? .WRD ,W?ALL ,W?ONE ,W?BOTH>
				  <EQUAL? .WRD ,W?EVERYT>>
			      <COND (<EQUAL? .NW ,W?OF>
				     <SETG P-LEN <- ,P-LEN 1>>
				     <SET PTR <+ .PTR ,P-LEXELEN>>)>)
			     (<OR <EQUAL? .WRD ,W?THEN ,W?PERIOD>
				  <AND <WT? .WRD ,PS?PREPOSITION>
				       <GET ,P-ITBL ,P-VERB>
				          ;"ADDED 4/27 FOR TURTLE,UP"
				       <NOT .FIRST??>>>
			      <SETG P-LEN <+ ,P-LEN 1>>
			      <PUT ,P-ITBL
				   <+ .NUM 1>
				   <REST ,P-LEXV <* .PTR 2>>>
			      <RETURN <- .PTR ,P-LEXELEN>>)
			     ;"This next clause was 2 clauses further down"
			     ;"This attempts to fix EDDIE, TURN ON COMPUTER"
			     (<AND .ANDFLG
				   <EQUAL? <GET ,P-ITBL ,P-VERB> 0>>
			      <SET PTR <- .PTR 4>>
			      <CHANGE-LEXV <+ .PTR 2> ,W?THEN>
			      <SETG P-LEN <+ ,P-LEN 2>>)
			     (<WT? .WRD ,PS?OBJECT>
			      <COND ;"First clause added 1/10/84 to fix
				      'verb AT synonym OF synonym' bug"
			            (<AND <G? ,P-LEN 0>
					  <EQUAL? .NW ,W?OF>
					  <NOT <EQUAL? .WRD ,W?ALL ,W?EVERYT
						            ,W?ONE>>>
				     T)
				    (<AND <EQUAL? <GET ,P-ITBL ,P-VERB>
						  ,ACT?SHOW ,ACT?HAND
						  ,ACT?FEED>
					  <EQUAL? .WRD ,W?HER>
					  <EQUAL? .NW ,W?SWORD>>
				     ;"horrific kludge for
				       'give her sword to...' --pdl")
				    (<AND <WT? .WRD
					       ,PS?ADJECTIVE
					       ,P1?ADJECTIVE>
					  <NOT <ZERO? .NW>>
					  <NOT <EQUAL? .NW
						       ,W?HIS ,W?HER ,W?MY>>
					  <OR <WT? .NW ,PS?OBJECT>
					      <WT? .NW ,PS?ADJECTIVE>>
					  <NOT <EQUAL? <GET ,P-ITBL ,P-VERB>
						       ,ACT?SHOW ,ACT?HAND
						       ,ACT?FEED>>>)
				    (<AND <NOT .ANDFLG>
					  <NOT <EQUAL? .NW ,W?BUT ,W?EXCEPT>>
					  <NOT <EQUAL? .NW ,W?AND ,W?COMMA>>>
				     <PUT ,P-ITBL
					  <+ .NUM 1>
					  <REST ,P-LEXV <* <+ .PTR 2> 2>>>
				     <RETURN .PTR>)
				    (T <SET ANDFLG <>>)>)
			     ;"next clause replaced by following on from games
			       with characters"
			     ;(<AND <OR ,P-MERGED
				       ,P-OFLAG
				       <NOT <EQUAL? <GET ,P-ITBL ,P-VERB> 0>>>
				   <OR <WT? .WRD ,PS?ADJECTIVE>
				       <WT? .WRD ,PS?BUZZ-WORD>>>)
			     (<OR <WT? .WRD ,PS?ADJECTIVE>
				  <WT? .WRD ,PS?BUZZ-WORD>>)
			     (<WT? .WRD ,PS?PREPOSITION> T)
			     (T
			      <CANT-USE .PTR>
			      <RFALSE>)>)
		      (T <UNKNOWN-WORD .PTR> <RFALSE>)>
		<SET LW .WRD>
		<SET FIRST?? <>>
		<SET PTR <+ .PTR ,P-LEXELEN>>>> 

<ROUTINE NUMBER? (PTR "AUX" CNT BPTR CHR (SUM 0) CCTR TMP XPTR)
	 <SET CNT <GETB <REST ,P-LEXV <* .PTR 2>> 2>>
	 <SET BPTR <GETB <REST ,P-LEXV <* .PTR 2>> 3>>
	 <REPEAT ()
		 <COND (<G? .SUM 10000> <RFALSE>)
		       (<L? <SET CNT <- .CNT 1>> 0>
			<RETURN>)
		       (T
			<SET CHR <GETB ,P-INBUF .BPTR>>
			<COND (<AND <L? .CHR 58>
				    <G? .CHR 47>>
			       <SET SUM <+ <* .SUM 10> <- .CHR 48>>>)
			      (<NOT <EQUAL? .CHR %<ASCII !\#>>>
			       <RFALSE>)>
			<SET BPTR <+ .BPTR 1>>)>>
	 <CHANGE-LEXV .PTR ,W?NUMBER>
	 ;"next COND handles inputs like 4,000"
	 <COND (<AND <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>> ,W?COMMA>
		     <G? ,P-LEN 1>>
		<SET XPTR <+ .PTR <* ,P-LEXELEN 2>>>
		<COND (<SET TMP <AFTER-COMMA-CHECK .XPTR>>
		       <SET CCTR <GETB ,P-LEXV <+ <* .PTR 2> 2>>>
		       <SET CCTR <+ .CCTR <GETB ,P-LEXV <+ <* .XPTR 2> 2>>>>
		       <SET CCTR <+ .CCTR 1>>
		       <PUTB ,P-LEXV
			     <+ <* .PTR 2> 2>
			     .CCTR>
		       <COND (<EQUAL? .TMP 1000> ;"returning 0 would = false"
			      <SET TMP 0>)>
		       <SET SUM <+ <* 1000 .SUM> .TMP>>
		       <SET CCTR <- ,P-LEN 2>>
		       <REPEAT ()
			 <COND (<DLESS? CCTR 0>
				<RETURN>)
			       (T
				<SET PTR <+ .PTR ,P-LEXELEN>>
				<SET XPTR <+ .PTR <* 2 ,P-LEXELEN>>>
				<CHANGE-LEXV .PTR
					     <GET ,P-LEXV .XPTR>>
				<PUTB ,P-LEXV <+ <* .PTR 2> 2>
				      <GETB ,P-LEXV
					    <+ <* .XPTR 2> 2>>>
				<PUTB ,P-LEXV <+ <* .PTR 2> 3>
				      <GETB ,P-LEXV
					    <+ <* .XPTR 2> 3>>>)>>
		       <SETG P-LEN <- ,P-LEN 2>>
		       <PUTB ,P-LEXV ,P-LEXWORDS
			     <- <GETB ,P-LEXV ,P-LEXWORDS> 2>>)>)>
	 <COND (<G? .SUM 10000> ;"this 10000 used to be 3000"
		<RFALSE>)>
	 <SETG P-NUMBER .SUM>
	 ,W?NUMBER>

<ROUTINE AFTER-COMMA-CHECK (PTR "AUX" CNT BPTR (CCTR 0) CHR (SUM 0))
	 <SET CNT <GETB <REST ,P-LEXV <* .PTR 2>> 2>>
	 <SET BPTR <GETB <REST ,P-LEXV <* .PTR 2>> 3>>
	 <REPEAT ()
		 <COND (<L? <SET CNT <- .CNT 1>> 0>
			<RETURN>)
		       (T
			<SET CHR <GETB ,P-INBUF .BPTR>>
			<SET CCTR <+ .CCTR 1>>
			<COND (<G? .CCTR 3>
			       <RETURN>)
			      (<AND <L? .CHR 58>
				    <G? .CHR 47>>
			       <SET SUM <+ <* .SUM 10> <- .CHR 48>>>)
			      (T
			       <RFALSE>)>
			<SET BPTR <+ .BPTR 1>>)>>
	 <COND (<NOT <EQUAL? .CCTR 3>> ;"only handles 3 digits after the comma"
		<RFALSE>)
	       (<ZERO? .SUM> ;"if it returned 0, the calling predicate becomes <>"
		<RETURN 1000>)
	       (T
		<RETURN .SUM>)>>

<GLOBAL P-NUMBER 0>

<ROUTINE ORPHAN-MERGE ("AUX" (CNT -1) TEMP VERB BEG END (ADJ <>) WRD) 
   <SETG P-OFLAG <>>
   <COND (<OR <EQUAL? <WT? <SET WRD <GET <GET ,P-ITBL ,P-VERBN> 0>>
			   ,PS?VERB ,P1?VERB>
		      <GET ,P-OTBL ,P-VERB>>
	      <WT? .WRD ,PS?ADJECTIVE>>
	  <SET ADJ T>)
	 (<AND <WT? .WRD ,PS?OBJECT ,P1?OBJECT>
	       <EQUAL? ,P-NCN 0>>
	  <PUT ,P-ITBL ,P-VERB 0>
	  <PUT ,P-ITBL ,P-VERBN 0>
	  <PUT ,P-ITBL ,P-NC1 <REST ,P-LEXV 2>>
	  <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>
	  <SETG P-NCN 1>)>
   <COND (<AND <NOT <ZERO? <SET VERB <GET ,P-ITBL ,P-VERB>>>>
	       <NOT .ADJ>
	       <NOT <EQUAL? .VERB <GET ,P-OTBL ,P-VERB>>>>
	  <RFALSE>)
	 (<EQUAL? ,P-NCN 2> <RFALSE>)
	 (<EQUAL? <GET ,P-OTBL ,P-NC1> 1>
	  <COND (<OR <EQUAL? <SET TEMP <GET ,P-ITBL ,P-PREP1>>
			     <GET ,P-OTBL ,P-PREP1>>
		     <ZERO? .TEMP>>
		 <COND (.ADJ
			<PUT ,P-OTBL ,P-NC1 <REST ,P-LEXV 2>>
			<COND (<ZERO? <GET ,P-ITBL ,P-NC1L>>
			       <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>)>
			<COND (<ZERO? ,P-NCN> <SETG P-NCN 1>)>)
		       (T
			<PUT ,P-OTBL ,P-NC1 <GET ,P-ITBL ,P-NC1>>
			;<PUT ,P-OTBL ,P-NC1L <GET ,P-ITBL ,P-NC1L>>)>
		 <PUT ,P-OTBL ,P-NC1L <GET ,P-ITBL ,P-NC1L>>)
		(T <RFALSE>)>)
	 (<EQUAL? <GET ,P-OTBL ,P-NC2> 1>
	  <COND (<OR <EQUAL? <SET TEMP <GET ,P-ITBL ,P-PREP1>>
			  <GET ,P-OTBL ,P-PREP2>>
		     <ZERO? .TEMP>>
		 <COND (.ADJ
			<PUT ,P-ITBL ,P-NC1 <REST ,P-LEXV 2>>
			<COND (<ZERO? <GET ,P-ITBL ,P-NC1L>>
			       <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>)>)>
		 <PUT ,P-OTBL ,P-NC2 <GET ,P-ITBL ,P-NC1>>
		 <PUT ,P-OTBL ,P-NC2L <GET ,P-ITBL ,P-NC1L>>
		 <SETG P-NCN 2>)
		(T <RFALSE>)>)
	 (,P-ACLAUSE
	  <COND (<AND <NOT <EQUAL? ,P-NCN 1>> <NOT .ADJ>>
		 <SETG P-ACLAUSE <>>
		 <RFALSE>)
		(T
		 <SET BEG <GET ,P-ITBL ,P-NC1>>
		 <COND (.ADJ <SET BEG <REST ,P-LEXV 2>> <SET ADJ <>>)>
		 <SET END <GET ,P-ITBL ,P-NC1L>>
		 <REPEAT ()
			 <SET WRD <GET .BEG 0>>
			 <COND (<EQUAL? .BEG .END>
				<COND (.ADJ <CLAUSE-WIN .ADJ> <RETURN>)
				      (T <SETG P-ACLAUSE <>> <RFALSE>)>)
			       (<OR <EQUAL? .WRD ,W?ALL ,W?EVERYT ,W?ONE> 
				    <AND <BTST <GETB .WRD ,P-PSOFF>
					       ,PS?ADJECTIVE> ;"same as WT?"
					 <ADJ-CHECK .WRD .ADJ .ADJ>>>
				<SET ADJ .WRD>)
			       (<EQUAL? .WRD ,W?ONE>
				<CLAUSE-WIN .ADJ>
				<RETURN>)
			       (<BTST <GETB .WRD ,P-PSOFF> ,PS?OBJECT>
				<COND (<EQUAL? .WRD ,P-ANAM>
				       <CLAUSE-WIN .ADJ>)
				      (T
				       <CLAUSE-WIN>)>
				<RETURN>)>
			 <SET BEG <REST .BEG ,P-WORDLEN>>
			 <COND (<EQUAL? .END 0>
				<SET END .BEG>
				<SETG P-NCN 1>
				<PUT ,P-ITBL ,P-NC1 <BACK .BEG 4>>
				<PUT ,P-ITBL ,P-NC1L .BEG>)>>)>)>
   <PUT ,P-VTBL 0 <GET ,P-OVTBL 0>>
   <PUTB ,P-VTBL 2 <GETB ,P-OVTBL 2>>
   <PUTB ,P-VTBL 3 <GETB ,P-OVTBL 3>>
   <PUT ,P-OTBL ,P-VERBN ,P-VTBL>
   <PUTB ,P-VTBL 2 0>
   ;<AND <NOT <EQUAL? <GET ,P-OTBL ,P-NC2> 0>> <SETG P-NCN 2>>
   <REPEAT ()
	   <COND (<G? <SET CNT <+ .CNT 1>> ,P-ITBLLEN>
		  <SETG P-MERGED T>
		  <RTRUE>)
		 (T <PUT ,P-ITBL .CNT <GET ,P-OTBL .CNT>>)>>
   T>

<ROUTINE CLAUSE-WIN ("OPT" (ADJ <>)) 
	<COND (.ADJ
	       <PUT ,P-ITBL ,P-VERB <GET ,P-OTBL ,P-VERB>>)
	      (ELSE <SET ADJ T>)>
	<PUT ,P-CCTBL ,CC-SBPTR ,P-ACLAUSE>
	<PUT ,P-CCTBL ,CC-SEPTR <+ ,P-ACLAUSE 1>>
	<COND (<EQUAL? ,P-ACLAUSE ,P-NC1>
	       <PUT ,P-CCTBL ,CC-OCLAUSE ,P-OCL1>)
	      (ELSE
	       <PUT ,P-CCTBL ,CC-OCLAUSE ,P-OCL2>)>
	<CLAUSE-COPY ,P-OTBL ,P-OTBL .ADJ>
	<AND <NOT <EQUAL? <GET ,P-OTBL ,P-NC2> 0>> <SETG P-NCN 2>>
	<SETG P-ACLAUSE <>>
	<RTRUE>>

;"Print undefined word in input.
   PTR points to the unknown word in P-LEXV"

<ROUTINE WORD-PRINT (CNT BUF)
	 <REPEAT ()
		 <COND (<DLESS? CNT 0> <RETURN>)
		       (ELSE
			<PRINTC <GETB ,P-INBUF .BUF>>
			<SET BUF <+ .BUF 1>>)>>>

<ROUTINE UNKNOWN-WORD (PTR "AUX" BUF)
	<PUT ,OOPS-TABLE ,O-PTR .PTR>
	<TELL "[I don't know the word \"">
	<WORD-PRINT <GETB <REST ,P-LEXV <SET BUF <* .PTR 2>>> 2>
		    <GETB <REST ,P-LEXV .BUF> 3>>
	<TELL ".\"]" CR>
	<SETG QUOTE-FLAG <>>
	<SETG P-OFLAG <>>>

<ROUTINE CANT-USE (PTR "OPTIONAL" (FOR-EACH-OTHER <>) "AUX" BUF)
	<TELL "[You used the word \"">
	<COND (.FOR-EACH-OTHER
	       <COND (<EQUAL? .PTR ,W?EACH>
	       	      <TELL "each">)
		     (T
		      <TELL "other">)>)
	      (T
	       <WORD-PRINT <GETB <REST ,P-LEXV <SET BUF <* .PTR 2>>> 2>
			   <GETB <REST ,P-LEXV .BUF> 3>>)>
	<TELL "\" in a way that I don't understand.]" CR>
	<STOP>>

;" Perform syntax matching operations, using P-ITBL as the source of
   the verb and adjectives for this input.  Returns false if no
   syntax matches, and does it's own orphaning.  If return is true,
   the syntax is saved in P-SYNTAX."

<GLOBAL P-SLOCBITS 0>

<CONSTANT P-SYNLEN 8>
<CONSTANT P-SBITS 0>
<CONSTANT P-SPREP1 1>
<CONSTANT P-SPREP2 2>
<CONSTANT P-SFWIM1 3>
<CONSTANT P-SFWIM2 4>
<CONSTANT P-SLOC1 5>
<CONSTANT P-SLOC2 6>
<CONSTANT P-SACTION 7>
<CONSTANT P-SONUMS 3>

<ROUTINE SYNTAX-CHECK ("AUX" SYN LEN NUM OBJ (DRIVE1 <>) (DRIVE2 <>) PREP VERB)
	<COND (<ZERO? <SET VERB <GET ,P-ITBL ,P-VERB>>>
	       <TELL ,NO-VERB>
	       <RFALSE>)>
	<SET SYN <GET ,VERBS <- 255 .VERB>>>
	<SET LEN <GETB .SYN 0>>
	<SET SYN <REST .SYN>>
	<REPEAT ()
		<SET NUM <BAND <GETB .SYN ,P-SBITS> ,P-SONUMS>>
		<COND (<G? ,P-NCN .NUM> T)
		      (<AND <NOT <L? .NUM 1>>
			    <ZERO? ,P-NCN>
			    <OR <ZERO? <SET PREP <GET ,P-ITBL ,P-PREP1>>>
				<EQUAL? .PREP <GETB .SYN ,P-SPREP1>>>>
		       <SET DRIVE1 .SYN>)
		      (<EQUAL? <GETB .SYN ,P-SPREP1> <GET ,P-ITBL ,P-PREP1>>
		       <COND (<AND <EQUAL? .NUM 2> <EQUAL? ,P-NCN 1>>
			      <SET DRIVE2 .SYN>)
			     (<EQUAL? <GETB .SYN ,P-SPREP2>
				      <GET ,P-ITBL ,P-PREP2>>
			      <SYNTAX-FOUND .SYN>
			      <RTRUE>)>)>
		<COND (<DLESS? LEN 1>
		       <COND (<OR .DRIVE1 .DRIVE2> <RETURN>)
			     (T
			      <RECOGNIZE>
			      <RFALSE>)>)
		      (T <SET SYN <REST .SYN ,P-SYNLEN>>)>>
	<COND (<AND .DRIVE1
		    <SET OBJ
			 <GWIM <GETB .DRIVE1 ,P-SFWIM1>
			       <GETB .DRIVE1 ,P-SLOC1>
			       <GETB .DRIVE1 ,P-SPREP1>>>>
	       <PUT ,P-PRSO ,P-MATCHLEN 1>
	       <PUT ,P-PRSO 1 .OBJ>
	       <SYNTAX-FOUND .DRIVE1>)
	      (<AND .DRIVE2
		    <SET OBJ
			 <GWIM <GETB .DRIVE2 ,P-SFWIM2>
			       <GETB .DRIVE2 ,P-SLOC2>
			       <GETB .DRIVE2 ,P-SPREP2>>>>
	       <PUT ,P-PRSI ,P-MATCHLEN 1>
	       <PUT ,P-PRSI 1 .OBJ>
	       <SYNTAX-FOUND .DRIVE2>)
	      ;(<EQUAL? .VERB ,ACT?FIND ;,ACT?WHAT>
	       <TELL "I can't answer that question." CR>
	       <RFALSE>)
	      (T
	       <COND (<EQUAL? ,WINNER ,PROTAGONIST>
		      <ORPHAN .DRIVE1 .DRIVE2>
		      <TELL "[Wh">)
		     (T
		      <TELL
"[Your command was not complete. Next time, type wh">)>
	       <COND (<EQUAL? .VERB ,ACT?WALK ,ACT?GO>
		      <TELL "ere">)
		     (<OR <AND .DRIVE1
			       <EQUAL? <GETB .DRIVE1 ,P-SFWIM1> ,ACTORBIT>>
			  <AND .DRIVE2
			       <EQUAL? <GETB .DRIVE2 ,P-SFWIM2> ,ACTORBIT>>>
		      <TELL "om">)
		     (T
		      <TELL "at">)>
	       <COND (<EQUAL? ,WINNER ,PROTAGONIST>
		      <TELL " do you want to ">)
		     (T
		      <TELL " you want" T ,WINNER " to ">)>
	       <VERB-PRINT>
	       <SETG P-OFLAG <>>
	       <COND (.DRIVE2
		      <SET PREP ,P-MERGED>
		      <SETG P-MERGED <>>
		      <CLAUSE-PRINT ,P-NC1 ,P-NC1L>
		      <SETG P-MERGED .PREP>)>
	       <PREP-PRINT <COND (.DRIVE1
				  <GETB .DRIVE1 ,P-SPREP1>)
				 (T
				  <GETB .DRIVE2 ,P-SPREP2>)>>
	       <COND (<EQUAL? ,WINNER ,PROTAGONIST>
		      <SETG P-OFLAG T>
		      <TELL "?]" CR>)
		     (T
		      <SETG P-OFLAG <>>
		      <TELL ".]" CR>)>
	       <RFALSE>)>>

<ROUTINE VERB-PRINT ("AUX" TMP)
	<SET TMP <GET ,P-ITBL ,P-VERBN>>	;"? ,P-OTBL?"
	<COND (<EQUAL? .TMP 0>
	       <TELL "tell">)
	      (<EQUAL? .TMP ,W?ZZMGCK>
	       <TELL "answer">)
	      (<ZERO? <GETB .TMP ;"P-VTBL" 2>>
	       <PRINTB <GET .TMP 0>>)
	      (T
	       <WORD-PRINT <GETB .TMP 2> <GETB .TMP 3>>
	       <PUTB .TMP ;"P-VTBL" 2 0>)>>

<ROUTINE CANT-ORPHAN ()
	 <TELL "\"I don't understand! What are you referring to?\"" CR>
	 <RFALSE>>

<ROUTINE ORPHAN (D1 D2 "AUX" (CNT -1))
	<COND (<NOT ,P-MERGED>
	       <PUT ,P-OCL1 ,P-MATCHLEN 0>
	       <PUT ,P-OCL2 ,P-MATCHLEN 0>)>
	<PUT ,P-OVTBL 0 <GET ,P-VTBL 0>>
	<PUTB ,P-OVTBL 2 <GETB ,P-VTBL 2>>
	<PUTB ,P-OVTBL 3 <GETB ,P-VTBL 3>>
	<REPEAT ()
		<COND (<IGRTR? CNT ,P-ITBLLEN> <RETURN>)
		      (T <PUT ,P-OTBL .CNT <GET ,P-ITBL .CNT>>)>>
	<COND (<EQUAL? ,P-NCN 2>
	       <PUT ,P-CCTBL ,CC-SBPTR ,P-NC2>
	       <PUT ,P-CCTBL ,CC-SEPTR ,P-NC2L>
	       <PUT ,P-CCTBL ,CC-OCLAUSE ,P-OCL2>
	       <CLAUSE-COPY ,P-ITBL ,P-OTBL>)>
	<COND (<NOT <L? ,P-NCN 1>>
	       <PUT ,P-CCTBL ,CC-SBPTR ,P-NC1>
	       <PUT ,P-CCTBL ,CC-SEPTR ,P-NC1L>
	       <PUT ,P-CCTBL ,CC-OCLAUSE ,P-OCL1>
	       <CLAUSE-COPY ,P-ITBL ,P-OTBL>)>
	<COND (.D1
	       <PUT ,P-OTBL ,P-PREP1 <GETB .D1 ,P-SPREP1>>
	       <PUT ,P-OTBL ,P-NC1 1>)
	      (.D2
	       <PUT ,P-OTBL ,P-PREP2 <GETB .D2 ,P-SPREP2>>
	       <PUT ,P-OTBL ,P-NC2 1>)>>

<ROUTINE CLAUSE-PRINT (BPTR EPTR "OPTIONAL" (THE? T)) 
	<BUFFER-PRINT <GET ,P-ITBL .BPTR> <GET ,P-ITBL .EPTR> .THE?>>

<ROUTINE BUFFER-PRINT (BEG END CP "AUX" (NOSP <>) WRD (FIRST?? T) (PN <>))
	 <REPEAT ()
		<COND (<EQUAL? .BEG .END>
		       <RETURN>)
		      (T
		       <COND (.NOSP
			      <SET NOSP <>>)
			     (T
			      <TELL " ">)>
		       <COND (<EQUAL? <SET WRD <GET .BEG 0>> ,W?PERIOD>
			      <SET NOSP T>)
			     (<EQUAL? .WRD ,W?ME ,W?MYSELF>
			      <PRINTD ,ME>
			      <SET PN T>)
			     (<NAME? .WRD>
			      <CAPITALIZE .BEG>
			      <SET PN T>)
			     (T
			      <COND (<AND .FIRST??
					  <NOT .PN>
					  .CP
					  <NOT
					   <EQUAL? .WRD ,W?MY ,W?HIS ,W?HER>>>
				     <TELL "the ">)>
			      <COND (<OR ,P-OFLAG ,P-MERGED>
				     <PRINTB .WRD>)
				    (<AND <EQUAL? .WRD ,W?IT ,W?THEM>
					  <ACCESSIBLE? ,P-IT-OBJECT>>
				     <TELL D ,P-IT-OBJECT>)
				    (<AND <EQUAL? .WRD ,W?HIM ,W?HIMSELF>
					  <ACCESSIBLE? ,P-HIM-OBJECT>>
				     <TELL D ,P-HIM-OBJECT>)
				    (<AND <EQUAL? .WRD ,W?HER ,W?HERSELF>
					  <ACCESSIBLE? ,P-HER-OBJECT>>
				     <TELL D ,P-HER-OBJECT>)
				    (T
				     <WORD-PRINT <GETB .BEG 2>
						 <GETB .BEG 3>>)>
			      <SET FIRST?? <>>)>)>
		<SET BEG <REST .BEG ,P-WORDLEN>>>>

<ROUTINE NAME? (WRD)
	 <COND (<OR <EQUAL? .WRD ,W?TRENT ,W?TIFFAN ,W?TIFF>
		    <EQUAL? .WRD ,W?THETA ,W?ELYSIA ,W?ELYSIUM>
		    <EQUAL? .WRD ,W?MITRE ,W?THORBAST ,W?FORD>
		    <EQUAL? .WRD ,W?VENUS ,W?CLEVELAND>>
		<RTRUE>)
	       (T
		<RFALSE>)>>

<ROUTINE CAPITALIZE (PTR)
	 <COND (<OR ,P-OFLAG ,P-MERGED>
		<PRINTB <GET .PTR 0>>)
	       (T
		<PRINTC <- <GETB ,P-INBUF <GETB .PTR 3>> 32>>
		<WORD-PRINT <- <GETB .PTR 2> 1> <+ <GETB .PTR 3> 1>>)>>

<ROUTINE PREP-PRINT (PREP "AUX" WRD)
	<COND (<NOT <ZERO? .PREP>>
	       <TELL " ">
	       <COND (<EQUAL? .PREP ,PR?THROUGH>
		      <TELL "through">)
		     (T
		      <SET WRD <PREP-FIND .PREP>>
		      <PRINTB .WRD>)>)>>
 
<ROUTINE CLAUSE-COPY (SRC DEST "OPT" (INSRT <>)
		      "AUX" OCL BEG END BB EE OBEG CNT B E)
	<SET BB <GET ,P-CCTBL ,CC-SBPTR>>
	<SET EE <GET ,P-CCTBL ,CC-SEPTR>>
	<SET OCL <GET ,P-CCTBL ,CC-OCLAUSE>>
	<SET BEG <GET .SRC .BB>>
	<SET END <GET .SRC .EE>>
	<SET OBEG <GET .OCL ,P-MATCHLEN>>
	<REPEAT ()
		<COND (<EQUAL? .BEG .END> <RETURN>)>
		<COND (<AND .INSRT
			    <EQUAL? ,P-ANAM <GET .BEG 0>>>
		       <COND (<EQUAL? .INSRT T>
			      <SET B <GET ,P-ITBL ,P-NC1>>
			      <SET E <GET ,P-ITBL ,P-NC1L>>
			      <REPEAT ()
				      <COND (<EQUAL? .B .E> <RETURN>)>
				      <CLAUSE-ADD <GET .B 0>>
				      <SET B <REST .B ,P-WORDLEN>>>)
			     (<NOT <EQUAL? .INSRT <GET .OCL 1>>>
			      <CLAUSE-ADD .INSRT>
			      <CLAUSE-ADD <GET .BEG 0>>)>)
		      (ELSE
		       <CLAUSE-ADD <GET .BEG 0>>)>
		<SET BEG <REST .BEG ,P-WORDLEN>>>
	<COND (<AND <EQUAL? .SRC .DEST> <G? .OBEG 0>>
	       <SET CNT <- <GET .OCL ,P-MATCHLEN> .OBEG>>
	       <PUT .OCL ,P-MATCHLEN 0>
	       <SET OBEG <+ .OBEG 1>>
	       <REPEAT ()
		       <CLAUSE-ADD <GET .OCL .OBEG>>
		       <COND (<ZERO? <SET CNT <- .CNT 2>>>
			      <RETURN>)>
		       <SET OBEG <+ .OBEG 2>>>
	       <SET OBEG 0>)>
	<PUT .DEST
	     .BB
	     <REST .OCL <+ <* .OBEG ,P-LEXELEN> 2>>>
	<PUT .DEST
	     .EE
	     <REST .OCL
		   <+ <* <GET .OCL ,P-MATCHLEN> ,P-LEXELEN> 2>>>>

<ROUTINE CLAUSE-ADD (WRD "AUX" OCL PTR)
	<SET OCL <GET ,P-CCTBL ,CC-OCLAUSE>>
	<SET PTR <+ <GET .OCL ,P-MATCHLEN> 2>>
	<PUT .OCL <- .PTR 1> .WRD>
	<PUT .OCL .PTR 0>
	<PUT .OCL ,P-MATCHLEN .PTR>>


 
<ROUTINE PREP-FIND (PREP "AUX" (CNT 0) SIZE)
	<SET SIZE <* <GET ,PREPOSITIONS 0> 2>>
	<REPEAT ()
		<COND (<IGRTR? CNT .SIZE> <RFALSE>)
		      (<EQUAL? <GET ,PREPOSITIONS .CNT> .PREP>
		       <RETURN <GET ,PREPOSITIONS <- .CNT 1>>>)>>>  
 
<ROUTINE SYNTAX-FOUND (SYN)
	<SETG P-SYNTAX .SYN>
	<SETG PRSA <GETB .SYN ,P-SACTION>>>
 
<GLOBAL P-GWIMBIT 0>
 
<ROUTINE GWIM (GBIT LBIT PREP "AUX" OBJ)
	<COND (<EQUAL? .GBIT ,RLANDBIT>
	       <RETURN ,ROOMS>)>
	<SETG P-GWIMBIT .GBIT>
	<SETG P-SLOCBITS .LBIT>
	<PUT ,P-MERGE ,P-MATCHLEN 0>
	<COND (<GET-OBJECT ,P-MERGE <>>
	       <SETG P-GWIMBIT 0>
	       <COND (<EQUAL? <GET ,P-MERGE ,P-MATCHLEN> 1>
		      <SET OBJ <GET ,P-MERGE 1>>
		      <TELL "[">
		      <COND (<AND <NOT <ZERO? .PREP>>
				  <NOT ,P-END-ON-PREP>>
			     <PRINTB <SET PREP <PREP-FIND .PREP>>>
			     <COND (<EQUAL? .PREP ,W?OUT>
				    <TELL " of">)>
			     <COND (<NOT <FSET? .OBJ ,NARTICLEBIT>>
				    <TELL " the ">)
				   (T
				    <TELL " ">)>)>
		      <TELL D .OBJ "]" CR>
		      .OBJ)>)
	      (T
	       <SETG P-GWIMBIT 0>
	       <RFALSE>)>>
 
<ROUTINE SNARF-OBJECTS ("AUX" PTR)
	<COND (<NOT <EQUAL? <SET PTR <GET ,P-ITBL ,P-NC1>> 0>>
	       <SETG P-PHR 0>
	       <SETG P-SLOCBITS <GETB ,P-SYNTAX ,P-SLOC1>>
	       <OR <SNARFEM .PTR <GET ,P-ITBL ,P-NC1L> ,P-PRSO> <RFALSE>>
	       <OR <ZERO? <GET ,P-BUTS ,P-MATCHLEN>>
		   <SETG P-PRSO <BUT-MERGE ,P-PRSO>>>)>
	<COND (<NOT <EQUAL? <SET PTR <GET ,P-ITBL ,P-NC2>> 0>>
	       <SETG P-PHR 1>
	       <SETG P-SLOCBITS <GETB ,P-SYNTAX ,P-SLOC2>>
	       <OR <SNARFEM .PTR <GET ,P-ITBL ,P-NC2L> ,P-PRSI> <RFALSE>>
	       <COND (<NOT <ZERO? <GET ,P-BUTS ,P-MATCHLEN>>>
		      <COND (<EQUAL? <GET ,P-PRSI ,P-MATCHLEN> 1>
			     <SETG P-PRSO <BUT-MERGE ,P-PRSO>>)
			    (T <SETG P-PRSI <BUT-MERGE ,P-PRSI>>)>)>)>
	<RTRUE>>  

<ROUTINE BUT-MERGE (TBL "AUX" LEN BUTLEN (CNT 1) (MATCHES 0) OBJ NTBL)
	<SET LEN <GET .TBL ,P-MATCHLEN>>
	<PUT ,P-MERGE ,P-MATCHLEN 0>
	<REPEAT ()
		<COND (<DLESS? LEN 0>
		       <RETURN>)
		      (<ZMEMQ <SET OBJ <GET .TBL .CNT>> ,P-BUTS>)
		      (T
		       <PUT ,P-MERGE <+ .MATCHES 1> .OBJ>
		       <SET MATCHES <+ .MATCHES 1>>)>
		<SET CNT <+ .CNT 1>>>
	<PUT ,P-MERGE ,P-MATCHLEN .MATCHES>
	<SET NTBL ,P-MERGE>
	<SETG P-MERGE .TBL>
	.NTBL>

<GLOBAL P-NAM <>>

<GLOBAL P-NAMW <TABLE 0 0>>

<GLOBAL P-ADJ <>>

<GLOBAL P-ADJW <TABLE 0 0>>

<GLOBAL P-PHR 0>

<GLOBAL P-ADVERB <>>

<GLOBAL P-ADJN <>>

<GLOBAL P-PRSO <ITABLE NONE 50>>

<GLOBAL P-PRSI <ITABLE NONE 50>>

<GLOBAL P-BUTS <ITABLE NONE 50>>

<GLOBAL P-MERGE <ITABLE NONE 50>>

<GLOBAL P-OCL1 <ITABLE NONE 50>>
<GLOBAL P-OCL2 <ITABLE NONE 50>>

<GLOBAL P-MATCHLEN 0>

<GLOBAL P-GETFLAGS 0>

<CONSTANT P-ALL 1>
<CONSTANT P-ONE 2>
<CONSTANT P-INHIBIT 4>

<ROUTINE SNARFEM (PTR EPTR TBL "AUX" (BUT <>) LEN WV WRD NW (WAS-ALL <>))
   <SETG P-AND <>>
   <COND (<EQUAL? ,P-GETFLAGS ,P-ALL>
	  <SET WAS-ALL T>)>
   <SETG P-GETFLAGS 0>
   ;<SETG P-CSPTR .PTR>
   ;<SETG P-CEPTR .EPTR>
   <PUT ,P-BUTS ,P-MATCHLEN 0>
   <PUT .TBL ,P-MATCHLEN 0>
   <SET WRD <GET .PTR 0>>
   <REPEAT ()
	   <COND (<EQUAL? .PTR .EPTR>
		  <SET WV <GET-OBJECT <OR .BUT .TBL>>>
		  <COND (.WAS-ALL <SETG P-GETFLAGS ,P-ALL>)>
		  <RETURN .WV>)
		 (T
		  <COND (<==? .EPTR <REST .PTR ,P-WORDLEN>>
			 <SET NW 0>)
			(T <SET NW <GET .PTR ,P-LEXELEN>>)>
		  <COND (<EQUAL? .WRD ,W?ALL ,W?BOTH ,W?EVERYT>
			 <COND (<NOT <MANY-CHECK ,P-PHR>>
				<RFALSE>)>
			 <SETG P-GETFLAGS ,P-ALL>
			 <COND (<EQUAL? .NW ,W?OF>
				<SET PTR <REST .PTR ,P-WORDLEN>>)>)
		        (<NAUGHTY-WORD? .WRD> ;"This clause at PARSER too"
			 <RFALSE>)
			(<EQUAL? .WRD ,W?BUT ,W?EXCEPT>
			 <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
			 <SET BUT ,P-BUTS>
			 <PUT .BUT ,P-MATCHLEN 0>)
			(<EQUAL? .WRD ,W?A ,W?ONE>
			 <COND (<NOT ,P-ADJ>
				<SETG P-GETFLAGS ,P-ONE>
				<COND (<EQUAL? .NW ,W?OF>
				       <SET PTR <REST .PTR ,P-WORDLEN>>)>)
			       (T
				<SETG P-NAM ,P-ONEOBJ>
				<OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
				<AND <ZERO? .NW> <RTRUE>>)>)
			(<AND <EQUAL? .WRD ,W?AND ,W?COMMA>
			      <NOT <EQUAL? .NW ,W?AND ,W?COMMA>>>
			 <SETG P-AND T>
			 <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
			 T)
			(<WT? .WRD ,PS?BUZZ-WORD>)
			(<EQUAL? .WRD ,W?AND ,W?COMMA>)
			(<EQUAL? .WRD ,W?OF>
			 <COND (<ZERO? ,P-GETFLAGS>
				<SETG P-GETFLAGS ,P-INHIBIT>)>)
			(<AND <SET WV <WT? .WRD ,PS?ADJECTIVE ,P1?ADJECTIVE>>
			      <ADJ-CHECK .WRD ,P-ADJ ,P-ADJN>
			      <NOT <EQUAL? .NW ,W?OF>>> ;"RFIX NO. 40"
			 <SETG P-ADJ .WV>
			 <SETG P-ADJN .WRD>)
			(<WT? .WRD ,PS?OBJECT ,P1?OBJECT>
			 <SETG P-NAM .WRD>
			 <SETG P-ONEOBJ .WRD>)>)>
	   <COND (<NOT <EQUAL? .PTR .EPTR>>
		  <SET PTR <REST .PTR ,P-WORDLEN>>
		  <SET WRD .NW>)>>>

<BUZZ ASSHOLE BITCH BASTARD COCKSU DAMN DAMNED FUCKED FUCKING SHITHEAD SHITTY>

<ROUTINE NAUGHTY-WORD? (WORD)
         <COND (<NOT <EQUAL? ,NAUGHTY-LEVEL 0>>
		<RFALSE>)
	       (<EQUAL? .WORD ,W?ASS ,W?ASSHOLE>
		<KNOW-WORD "A">)
	       (<EQUAL? .WORD ,W?BASTARD ,W?BITCH>
		<KNOW-WORD "B">)
	       (<EQUAL? .WORD ,W?COCK ,W?COCKSU ,W?CUNT>
		<KNOW-WORD "C">)
	       (<EQUAL? .WORD ,W?DAMN ,W?DAMNED>
		<KNOW-WORD "D">)
	       (<EQUAL? .WORD ,W?FUCK ,W?FUCKED ,W?FUCKING>
		<KNOW-WORD "F">)
	       (<EQUAL? .WORD ,W?SHIT ,W?SHITHEAD>
		<KNOW-WORD "S">)
	       (T
		<RFALSE>)>>

<ROUTINE KNOW-WORD (LETTER)
	 <TELL "[I don't know the " .LETTER "-word.]" CR>>

;"grabs the first adjective, unless it comes across a special-cased adjective"
<ROUTINE ADJ-CHECK (WRD ADJ ADJN)
	 <COND (<NOT .ADJ>
		<RTRUE>)
	       (<AND <EQUAL? .WRD ,W?RETURN>
		     <EQUAL? .ADJN ,W?COIN>>
		<RTRUE>)
	       (<EQUAL? .WRD ,W?NARROW ,W?WIDE>
		<RTRUE>)
	       (<EQUAL? .WRD ,W?PURPLE ,W?ORANGE>
		<RTRUE>)
	       (T
		<RFALSE>)>>		

<CONSTANT SH 128> 
<CONSTANT SC 64>
<CONSTANT SIR 32>
<CONSTANT SOG 16>
<CONSTANT STAKE 8>
<CONSTANT SMANY 4>
<CONSTANT SHAVE 2>

<ROUTINE GET-OBJECT (TBL "OPTIONAL" (VRB T)
		      "AUX" ;GEN BITS LEN XBITS TLEN (GCHECK <>) (OLEN 0) OBJ)
	 <SET XBITS ,P-SLOCBITS>
	 <SET TLEN <GET .TBL ,P-MATCHLEN>>
	 <COND (<BTST ,P-GETFLAGS ,P-INHIBIT> <RTRUE>)>
	 <COND (<AND <NOT ,P-NAM>
		     ,P-ADJ>
		<COND (<WT? ,P-ADJN ,PS?OBJECT ,P1?OBJECT>
		       <SETG P-NAM ,P-ADJN>
		       <SETG P-ADJ <>>
		       <SETG P-ADJN <>>)
		      (<SET BITS <WT? ,P-ADJN ,PS?DIRECTION ,P1?DIRECTION>>
		       <SETG P-DIRECTION .BITS>)>)> ;"Added by JW 4-17-85"
	 <COND (<AND <NOT ,P-NAM>
		     <NOT ,P-ADJ>
		     <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>>
		     <ZERO? ,P-GWIMBIT>>
		<COND (.VRB
		       <TELL ,NOUN-MISSING>)>
		<RFALSE>)>
	 <COND (<OR <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>> <ZERO? ,P-SLOCBITS>>
		<SETG P-SLOCBITS -1>)>
	 <SETG P-TABLE .TBL>
	 <PROG ()
	       <COND (.GCHECK
		      <GLOBAL-CHECK .TBL>)
		     (T
		      <COND (<OR ,LIT <VERB? TELL>>
			     <FCLEAR ,PROTAGONIST ,TRANSBIT>
			     <DO-SL ,HERE ,SOG ,SIR>
			     <FSET ,PROTAGONIST ,TRANSBIT>)
			    (<AND <FSET? <LOC ,PROTAGONIST> ,VEHBIT>
				  <THIS-IT? <LOC ,PROTAGONIST>>>
			     <OBJ-FOUND <LOC ,PROTAGONIST> .TBL>)>
		      <DO-SL ,PROTAGONIST ,SH ,SC>)>
	       <SET LEN <- <GET .TBL ,P-MATCHLEN> .TLEN>>
	       <COND (<BTST ,P-GETFLAGS ,P-ALL> ;<AND * <NOT <EQUAL? .LEN 0>>>)
		     ;(<BTST ,P-GETFLAGS ,P-ONE>
		      <COND (<NOT <EQUAL? .LEN 1>>
			     <PUT .TBL 1 <GET .TBL <RANDOM .LEN>>>
			     <TELL "[How about the " D <GET .TBL 1> "?]" CR>
			     <PUT .TBL ,P-MATCHLEN 1>)
			    (ELSE
			     <TELL ,YOU-CANT "see one here!" CR>
			     <RFALSE>)>)
		     (<AND <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>>
			   <OR <G? .LEN 1>
			     <AND <ZERO? .LEN> <NOT <EQUAL? ,P-SLOCBITS -1>>>>>
		      <COND (<EQUAL? ,P-SLOCBITS -1>
			     <SETG P-SLOCBITS .XBITS>
			     <SET OLEN .LEN>
			     <PUT .TBL
				  ,P-MATCHLEN
				  <- <GET .TBL ,P-MATCHLEN> .LEN>>
			     <AGAIN>)
			    (T
			     <PUT-ADJ-NAM>
			     <COND (<ZERO? .LEN> 
				    <SET LEN .OLEN>)>
			     <COND (<AND ,P-NAM
				      <SET OBJ <GET .TBL <+ .TLEN 1>>>
				      <SET OBJ <APPLY <GETP .OBJ ,P?GENERIC>>>>
				    <COND (<EQUAL? .OBJ ,NOT-HERE-OBJECT>
					   <RFALSE>)>
				    <PUT .TBL 1 .OBJ>
				    <PUT .TBL ,P-MATCHLEN 1>
				    <SETG P-NAM <>>
				    <SETG P-ADJ <>>
				    <RTRUE>)
			      	   (<AND .VRB ;".VRB added 8/14/84 by JW"
					 <NOT <EQUAL? ,WINNER ,PROTAGONIST>>>
				    <CANT-ORPHAN>
				    <SETG P-NAM <>>
				    <SETG P-ADJ <>>
				    <RFALSE>)
				   (<AND .VRB ,P-NAM>
				    <WHICH-PRINT .TLEN .LEN .TBL>
				    <SETG P-ACLAUSE
					  <COND (<EQUAL? .TBL ,P-PRSO> ,P-NC1)
						(T ,P-NC2)>>
				    <SETG P-AADJ ,P-ADJ>
				    <SETG P-ANAM ,P-NAM>
				    <ORPHAN <> <>>
				    <SETG P-OFLAG T>)
				   (.VRB
				    <TELL ,NOUN-MISSING>)>
			     <SETG P-NAM <>>
			     <SETG P-ADJ <>>
			     <RFALSE>)>)
		     (<AND <ZERO? .LEN> .GCHECK>
		      <PUT-ADJ-NAM>
		      <COND (.VRB
			     <SETG P-SLOCBITS .XBITS>
			     <COND (<OR ,LIT
					<EQUAL? ,PRSA ,V?TELL>
					<EQUAL? ,PRSA ,V?WHERE ,V?WHAT>>
				    ;"Changed 6/10/83 - MARC"
				    <OBJ-FOUND ,NOT-HERE-OBJECT .TBL>
				    <SETG P-XNAM ,P-NAM>
				    <SETG P-XADJ ,P-ADJ>
				    <SETG P-XADJN ,P-ADJN>
				    <SETG P-NAM <>>
				    <SETG P-ADJ <>>
				    <SETG P-ADJN <>>
				    <RTRUE>)
				   (T
				    <TELL ,TOO-DARK CR>)>)>
		      <SETG P-NAM <>>
		      <SETG P-ADJ <>>
		      <RFALSE>)
		     (<ZERO? .LEN> <SET GCHECK T> <AGAIN>)>
	       <SETG P-SLOCBITS .XBITS>
	       <PUT-ADJ-NAM>
	       <SETG P-NAM <>>
	       <SETG P-ADJ <>>
	       <RTRUE>>>

<ROUTINE PUT-ADJ-NAM ()
	 <COND (<NOT <EQUAL? ,P-NAM ,W?IT>>
		<PUT ,P-NAMW ,P-PHR ,P-NAM>
		<PUT ,P-ADJW ,P-PHR ,P-ADJ>)>>

<CONSTANT LAST-OBJECT 0> ;"ZILCH should stick the # of the last object here"

<ROUTINE MOBY-FIND (TBL "AUX" (OBJ 1) LEN FOO NAM ADJ)
  <SET NAM ,P-NAM>
  <SET ADJ ,P-ADJ>
  <SETG P-NAM ,P-XNAM>
  <SETG P-ADJ ,P-XADJ>
  ;<COND (,DEBUG
	 <TELL "[MOBY-FINDing; P-NAM=">
	 <PRINTB ,P-NAM>
	 <TELL "]" CR>)>
  <PUT .TBL ,P-MATCHLEN 0>
  %<COND (<GASSIGNED? ZILCH>	;<NOT <ZERO? <GETB 0 18>>>	;"ZIP case"
	 '<PROG ()
	 <REPEAT ()
		 <COND (<AND ;<SET FOO <META-LOC .OBJ T>>
			     <NOT <IN? .OBJ ,ROOMS>>
			     <SET FOO <THIS-IT? .OBJ>>>
			<SET FOO <OBJ-FOUND .OBJ .TBL>>)>
		 <COND (<IGRTR? OBJ ,LAST-OBJECT>
			<RETURN>)>>>)
	(T		;"ZIL case"
	 '<PROG ()
	 <SETG P-SLOCBITS -1>
	 <SET FOO <FIRST? ,ROOMS>>
	 <REPEAT ()
		 <COND (<NOT .FOO>
			<RETURN>)
		       (T
			<SEARCH-LIST .FOO .TBL ,P-SRCALL T>
			<SET FOO <NEXT? .FOO>>)>>
	 <DO-SL ,LOCAL-GLOBALS 1 1 .TBL T>
	 <SEARCH-LIST ,ROOMS .TBL ,P-SRCTOP T>>)>
  <COND (<EQUAL? <SET LEN <GET .TBL ,P-MATCHLEN>> 1>
	 <SETG P-MOBY-FOUND <GET .TBL 1>>)>
  <SETG P-NAM .NAM>
  <SETG P-ADJ .ADJ>
  <RETURN .LEN>>

<GLOBAL P-MOBY-FOUND <>>
<GLOBAL P-MOBY-FLAG <>>
<GLOBAL P-XNAM <>>
<GLOBAL P-XADJ <>>
<GLOBAL P-XADJN <>>

<ROUTINE WHICH-PRINT (TLEN LEN TBL "AUX" OBJ RLEN)
	 <SET RLEN .LEN>
	 <TELL "[Which">
         <COND (<OR ,P-OFLAG
		    ,P-MERGED
		    ,P-AND>
		<TELL " ">
		<PRINTB ,P-NAM>)
	       (<EQUAL? .TBL ,P-PRSO>
		<CLAUSE-PRINT ,P-NC1 ,P-NC1L <>>)
	       (T
		<CLAUSE-PRINT ,P-NC2 ,P-NC2L <>>)>
	 <TELL " do you mean, ">
	 <REPEAT ()
		 <SET TLEN <+ .TLEN 1>>
		 <SET OBJ <GET .TBL .TLEN>>
		 <COND (<NOT <FSET? .OBJ ,NARTICLEBIT>>
			<TELL "the ">)>
		 <TELL D .OBJ>
		 <COND (<EQUAL? .LEN 2>
		        <COND (<NOT <EQUAL? .RLEN 2>>
			       <TELL ",">)>
		        <TELL " or ">)
		       (<G? .LEN 2>
			<TELL ", ">)>
		 <COND (<L? <SET LEN <- .LEN 1>> 1>
		        <TELL "?]" CR>
		        <RETURN>)>>>

<ROUTINE GLOBAL-CHECK (TBL "AUX" LEN RMG RMGL (CNT 0) OBJ OBITS FOO)
	<SET LEN <GET .TBL ,P-MATCHLEN>>
	<SET OBITS ,P-SLOCBITS>
	<COND (<SET RMG <GETPT ,HERE ,P?GLOBAL>>
	       <SET RMGL <- <PTSIZE .RMG> 1>>
	       <REPEAT ()
		       <COND (<THIS-IT? <SET OBJ <GETB .RMG .CNT>>>
			      <OBJ-FOUND .OBJ .TBL>)>
		       <COND (<IGRTR? CNT .RMGL>
			      <RETURN>)>>)>
	<COND (<SET RMG <GETP ,HERE ,P?THINGS>>
	       <SET RMGL <GET .RMG 0>>
	       <SET CNT 0>
	       <REPEAT ()
		<COND (<AND ,P-NAM
			    <NOT <EQUAL? ,P-NAM <GET .RMG <+ .CNT 1>>>>>)
		      ;(<AND ,P-ADJ
			    <NOT <EQUAL? ,P-ADJN <GET .RMG <+ .CNT 2>>>>>)
		      (<AND ,P-ADJ
			    <NOT <EQUAL? ,P-ADJ
					 <WT? <GET .RMG <+ .CNT 2>>
					      ,PS?ADJECTIVE ,P1?ADJECTIVE>>>>)
		      (<OR ,P-NAM ,P-ADJ>
		       ;<SETG P-PNAM ,P-NAM>
		       ;<COND (,P-ADJ
			      <SETG P-PADJN ,P-ADJN>)
			     (T
			      <SETG P-PADJN <>>)>
		       <SETG LAST-PSEUDO-LOC ,HERE>
		       <PUTP ,PSEUDO-OBJECT ,P?ACTION <GET .RMG <+ .CNT 3>>>
		       <SET FOO <BACK <GETPT ,PSEUDO-OBJECT ,P?ACTION> 5>>
		       <SET RMG <GET .RMG <+ .CNT 1>>>
		       <PUT .FOO 0 <GET .RMG 0>>
		       <PUT .FOO 1 <GET .RMG 1>>
		       <OBJ-FOUND ,PSEUDO-OBJECT .TBL>
		       <RETURN>)>
		<SET CNT <+ .CNT 3>>
		<COND (<NOT <L? .CNT .RMGL>>
		       <RETURN>)>>)>
	<COND (<EQUAL? <GET .TBL ,P-MATCHLEN> .LEN>
	       <SETG P-SLOCBITS -1>
	       <SETG P-TABLE .TBL>
	       <DO-SL ,GLOBAL-OBJECTS 1 1>
	       <SETG P-SLOCBITS .OBITS>
	       ;<COND (<AND <ZERO? <GET .TBL ,P-MATCHLEN>>
			   <EQUAL? ,PRSA ,V?LOOK-INSIDE ,V?SEARCH ,V?EXAMINE>>
		      <DO-SL ,ROOMS 1 1>)>)>>
 
<ROUTINE DO-SL (OBJ BIT1 BIT2 "AUX" BTS)
	<COND (<BTST ,P-SLOCBITS <+ .BIT1 .BIT2>>
	       <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCALL>)
	      (T
	       <COND (<BTST ,P-SLOCBITS .BIT1>
		      <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCTOP>)
		     (<BTST ,P-SLOCBITS .BIT2>
		      <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCBOT>)
		     (T <RTRUE>)>)>>  
 
<CONSTANT P-SRCBOT 2> 
<CONSTANT P-SRCTOP 0>
<CONSTANT P-SRCALL 1>

<ROUTINE SEARCH-LIST (OBJ TBL LVL "AUX" FLS NOBJ)
	<COND (<SET OBJ <FIRST? .OBJ>>
	       <REPEAT ()
		       <COND (<AND <NOT <EQUAL? .LVL ,P-SRCBOT>>
				   <GETPT .OBJ ,P?SYNONYM>
				   <THIS-IT? .OBJ>>
			      <OBJ-FOUND .OBJ .TBL>)>
		       <COND (<AND <OR <NOT <EQUAL? .LVL ,P-SRCTOP>>
				       <FSET? .OBJ ,SEARCHBIT>
				       <FSET? .OBJ ,SURFACEBIT>>
				   <SET NOBJ <FIRST? .OBJ>>>
			      <COND (<OR <FSET? .OBJ ,OPENBIT>
					 <FSET? .OBJ ,TRANSBIT>
					 ,P-MOBY-FLAG>
				     <SET FLS
					  <SEARCH-LIST
					   .OBJ
					   .TBL
					   <COND (<FSET? .OBJ ,SURFACEBIT>
						  ,P-SRCALL)
						 (<FSET? .OBJ ,SEARCHBIT>
						  ,P-SRCALL)
						 (T ,P-SRCTOP)>>>)>)>
		       <COND (<SET OBJ <NEXT? .OBJ>>) (T <RETURN>)>>)>> 
 
<ROUTINE OBJ-FOUND (OBJ TBL "AUX" PTR)
	<SET PTR <GET .TBL ,P-MATCHLEN>>
	<PUT .TBL <+ .PTR 1> .OBJ>
	<PUT .TBL ,P-MATCHLEN <+ .PTR 1>>>

<ROUTINE TAKE-CHECK () 
	<AND <ITAKE-CHECK ,P-PRSO <GETB ,P-SYNTAX ,P-SLOC1>>
	     <ITAKE-CHECK ,P-PRSI <GETB ,P-SYNTAX ,P-SLOC2>>>> 

<ROUTINE ITAKE-CHECK (TBL IBITS "AUX" PTR OBJ TAKEN) ;"changed by MARC 11/83"
   <COND (<AND <SET PTR <GET .TBL ,P-MATCHLEN>>
	       <OR <BTST .IBITS ,SHAVE>
	           <BTST .IBITS ,STAKE>>>
	  <REPEAT ()
	    <COND (<L? <SET PTR <- .PTR 1>> 0>
		   <RETURN>)
		  (T
		   <SET OBJ <GET .TBL <+ .PTR 1>>>
		   <COND (<EQUAL? .OBJ ,IT>
			  <COND (<NOT <VISIBLE? ,P-IT-OBJECT>>
				 <REFERRING>
				 <RFALSE>)
				(T
				 <SET OBJ ,P-IT-OBJECT>)>)
			 (<EQUAL? .OBJ ,HIM>
			  <COND (<NOT <VISIBLE? ,P-HIM-OBJECT>>
				 <REFERRING T>
				 <RFALSE>)
				(T
				 <SET OBJ ,P-HIM-OBJECT>)>)
			 (<EQUAL? .OBJ ,HER>
			  <COND (<NOT <VISIBLE? ,P-HER-OBJECT>>
				 <REFERRING T>
				 <RFALSE>)
				(T
				 <SET OBJ ,P-HER-OBJECT>)>)>
		   <COND (<OR <ULTIMATELY-IN? .OBJ>
			      <AND <EQUAL? .OBJ ,RAFT>
				   ,RAFT-HELD> ;"for LET GO OF RAFT"
	                      <EQUAL? .OBJ ,INTNUM ,HANDS ,HAND-COVER>>
			  T)
			 (T
			  <SETG PRSO .OBJ>
			  <COND (<FSET? .OBJ ,TRYTAKEBIT>
				 <SET TAKEN T>)
				(<UNTOUCHABLE? .OBJ>
				 <SET TAKEN T>)
				(<NOT <EQUAL? ,WINNER ,PROTAGONIST>>
				 <SET TAKEN <>>)
				(<AND <BTST .IBITS ,STAKE>
				      <EQUAL? <ITAKE <>> T>>
				 <SET TAKEN <>>)
				(T
				 <SET TAKEN T>)>
			  <COND (<AND .TAKEN
				      <BTST .IBITS ,SHAVE>>
				 <COND (<L? 1 <GET .TBL ,P-MATCHLEN>>
				        <TELL ,YNH " all those things!" CR>
					<RFALSE>)
				       (<EQUAL? .OBJ ,NOT-HERE-OBJECT>
					<TELL ,YOU-CANT "see that here!" CR>
					<RFALSE>)>
				 <COND (<EQUAL? ,WINNER ,PROTAGONIST>
					<TELL ,YNH>)
				       (T
					<TELL
"It doesn't look like" T ,WINNER " has">)>
				 <THIS-IS-IT .OBJ>
				 <TELL TR .OBJ>
				 <RFALSE>)
				(<AND <NOT .TAKEN>
				      <NOT <IN? ,PROTAGONIST .OBJ>>
				      <EQUAL? ,WINNER ,PROTAGONIST>>
				 <TELL "[taking" T .OBJ " first]" CR>)>)>)>>)
	       (T)>>

<ROUTINE MANY-CHECK ("OPTIONAL" (PHR 2)"AUX" (LOSS <>) TMP)
	<COND (<AND <ZERO? .PHR>
		    <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC1> ,SMANY>>>
	       <SET LOSS 1>)
	      (<AND <EQUAL? .PHR 1>
		    <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC2> ,SMANY>>>
	       <SET LOSS 2>)
	      (<AND <EQUAL? .PHR 2>
		    <G? <GET ,P-PRSO ,P-MATCHLEN> 1>
		    <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC1> ,SMANY>>>
	       <SET LOSS 1>)
	      (<AND <EQUAL? .PHR 2>
		    <G? <GET ,P-PRSI ,P-MATCHLEN> 1>
		    <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC2> ,SMANY>>>
	       <SET LOSS 2>)>
	<COND (.LOSS
	       <TELL "[" ,YOU-CANT "use multiple ">
	       <COND (<EQUAL? .LOSS 2>
		      <TELL "in">)>
	       <TELL "direct objects with \"">
	       <SET TMP <GET ,P-ITBL ,P-VERBN>>
	       <COND (<ZERO? .TMP>
		      <TELL "tell">)
		     (<OR ,P-OFLAG ,P-MERGED>
		      <PRINTB <GET .TMP 0>>)
		     (T
		      <WORD-PRINT <GETB .TMP 2> <GETB .TMP 3>>)>
	       <TELL "\".]" CR>
	       <RFALSE>)
	      (T)>>  
 
<ROUTINE ZMEMQ (ITM TBL "OPTIONAL" (SIZE -1) "AUX" (CNT 1)) 
	<COND (<NOT .TBL> <RFALSE>)>
	<COND (<NOT <L? .SIZE 0>> <SET CNT 0>)
	      (ELSE <SET SIZE <GET .TBL 0>>)>
	<REPEAT ()
		<COND (<EQUAL? .ITM <GET .TBL .CNT>>
		       <RTRUE>)
		      (<IGRTR? CNT .SIZE>
		       <RFALSE>)>>>

<ROUTINE ZMEMQB (ITM TBL SIZE "AUX" (CNT 0)) 
	<REPEAT ()
		<COND (<EQUAL? .ITM <GETB .TBL .CNT>>
		       <RTRUE>)
		      (<IGRTR? CNT .SIZE>
		       <RFALSE>)>>>

<ROUTINE LIT? (RM "OPTIONAL" (RMBIT T) "AUX" OHERE (LIT <>))
	<SETG P-GWIMBIT ,ONBIT>
	<SET OHERE ,HERE>
	<SETG HERE .RM>
	<COND (<AND .RMBIT
		    <FSET? .RM ,ONBIT>>
	       <SET LIT T>)
	      (T
	       <PUT ,P-MERGE ,P-MATCHLEN 0>
	       <SETG P-TABLE ,P-MERGE>
	       <SETG P-SLOCBITS -1>
	       <COND (<EQUAL? .OHERE .RM>
		      <DO-SL ,WINNER 1 1>
		      <COND (<AND <NOT <EQUAL? ,WINNER ,PROTAGONIST>>
				  <IN? ,PROTAGONIST .RM>>
			     <DO-SL ,PROTAGONIST 1 1>)>)>
	       <DO-SL .RM 1 1>
	       <COND (<G? <GET ,P-TABLE ,P-MATCHLEN> 0>
		      <SET LIT T>)>)>
	<SETG HERE .OHERE>
	<SETG P-GWIMBIT 0>
	.LIT>

<ROUTINE PRSO-PRINT ("AUX" PTR)
	 <COND (<OR ,P-MERGED
		    <EQUAL? <GET <SET PTR <GET ,P-ITBL ,P-NC1>> 0> ,W?IT>>
		<TELL " " D ,PRSO>)
	       (T
		<BUFFER-PRINT .PTR <GET ,P-ITBL ,P-NC1L> <>>)>>

<ROUTINE PRSI-PRINT ("AUX" PTR)
	 <COND (<OR ,P-MERGED
		    <EQUAL? <GET <SET PTR <GET ,P-ITBL ,P-NC2>> 0> ,W?IT>>
		<TELL " " D ,PRSI>)
	       (T
		<BUFFER-PRINT .PTR <GET ,P-ITBL ,P-NC2L> <>>)>>

;"former CRUFTY.ZIL routine"

<ROUTINE THIS-IT? (OBJ "AUX" SYNS) 
 <COND (<FSET? .OBJ ,INVISIBLE>
	<RFALSE>)
       (<AND ,P-NAM
	     <NOT <ZMEMQ ,P-NAM
			 <SET SYNS <GETPT .OBJ ,P?SYNONYM>>
			 <- </ <PTSIZE .SYNS> 2> 1>>>>
	<RFALSE>)
       (<AND ,P-ADJ
	     <OR <NOT <SET SYNS <GETPT .OBJ ,P?ADJECTIVE>>>
		 <NOT <ZMEMQB ,P-ADJ .SYNS <- <PTSIZE .SYNS> 1>>>>>
	<RFALSE>)
       (<AND <NOT <ZERO? ,P-GWIMBIT>> <NOT <FSET? .OBJ ,P-GWIMBIT>>>
	<RFALSE>)>
 <RTRUE>>