;       Z88 Small C+ Run time Library
;       Moved functions over to proper libdefs
;       To make startup code smaller and neater!
;
;       6/9/98  djm

SECTION seg_code_sccz80

PUBLIC l_neg

EXTERN l_neg_hl

defc l_neg = l_neg_hl
