!cpu 6502
!to "pt3_test",plain
*=$800
;=================
; VMW PT3_LIB test
;=================
; template for using the pt3_lib

; zero page definitions
!src    "zp.inc"

; some firmware locations
!src    "hardware.inc"

; Location the files load at.
; If you change this, you need to update the Makefile

PT3_LOC = song

; the below will make for more compact code, at the expense
; of using $80 - $ff zero page addresses by the decoder.

; PT3_USE_ZERO_PAGE = 1


; Comment this to disable Apple IIc support which will free a small amount
; of room

PT3_ENABLE_APPLE_IIC = 1


        ;=============================
        ; Setup
        ;=============================
pt3_setup:
        jsr     HOME
        jsr     TEXT

        ;===============
        ; init variables
        ;===============

        lda     #0
        sta     DONE_PLAYING
;       lda     #1
        sta     LOOP            ; change to 1 to loop forever


        ;=======================
        ; Detect Apple II Model
        ;========================
        ; IRQ setup is different on IIc
        ; You can possibly skip this if you only care about II+/IIe

!ifdef PT3_ENABLE_APPLE_IIC {
        jsr     detect_appleii_model
}

        ;=======================
        ; Detect mockingboard
        ;========================

        jsr     print_mockingboard_detect       ; print message

        jsr     mockingboard_detect             ; call detection routine

        bcs     mockingboard_found

        jsr     print_mocking_notfound

        ; possibly can't detect on IIc so just try with slot#4 anyway
        ; even if not detected

        jmp     setup_interrupt

mockingboard_found:

        ; print found message


        ; modify message to print slot value

        lda     MB_ADDR_H
        sec
        sbc     #$10
        sta     found_message+11

        jsr     print_mocking_found

        ;==================================================
        ; patch the playing code with the proper slot value
        ;==================================================

        jsr     mockingboard_patch

setup_interrupt:

        ;=======================
        ; Set up 50Hz interrupt
        ;========================

        jsr     mockingboard_init
        jsr     mockingboard_setup_interrupt

        ;============================
        ; Init the Mockingboard
        ;============================

        jsr     reset_ay_both
        jsr     clear_ay_both

        ;==================
        ; init song
        ;==================

        jsr     pt3_init_song

        ;============================
        ; Enable 6502 interrupts
        ;============================
start_interrupts:
        cli             ; clear interrupt mask


        ;============================
        ; Loop forever
        ;============================
forever_loop:
        jmp     forever_loop


;========================================
;========================================

; Helper routines below

;========================================
;========================================

        ;==================================
        ; Print mockingboard detect message
        ;==================================
        ; note: on IIc must do this before enabling interrupt
        ;       as we disable ROM (COUT won't work?)

print_mockingboard_detect:
        lda     APPLEII_MODEL
        sta     apple_message+17

        ; print detection message for Apple II type
        ldy     #0
print_apple_message:
        lda     apple_message,Y         ; load loading message
        beq     done_apple_message
        ora     #$80
        jsr     COUT
        iny
        jmp     print_apple_message
done_apple_message:
        jsr     CROUT1


        ; print detection message
        ldy     #0
print_mocking_message:
        lda     mocking_message,Y               ; load loading message
        beq     done_mocking_message
        ora     #$80
        jsr     COUT
        iny
        jmp     print_mocking_message
done_mocking_message:
        jsr     CROUT1

        rts

print_mocking_notfound:

        ldy     #0
print_not_message:
        lda     not_message,Y           ; load loading message
        beq     print_not_message_done
        ora     #$80
        jsr     COUT
        iny
        jmp     print_not_message
print_not_message_done:
        rts

print_mocking_found:
        ldy     #0
print_found_message:
        lda     found_message,Y         ; load loading message
        beq     done_found_message
        ora     #$80
        jsr     COUT
        iny
        jmp     print_found_message
done_found_message:

        rts

;=========
; strings
;=========
apple_message:          !text "DETECTED APPLE II  ", 0

mocking_message:        !text "LOOKING FOR MOCKINGBOARD: ", 0
not_message:            !text "NOT "
found_message:          !text "FOUND SLOT#4", 0



;=========
; vars
;=========

;=========
;routines
;=========

!ifdef PT3_ENABLE_APPLE_IIC {
!src    "pt3_lib_detect_model.s"
}

!src    "pt3_lib_core.s"
!src    "pt3_lib_init.s"
!src    "pt3_lib_mockingboard_setup.s"
!src    "pt3_lib_irq_handler.s"
; if you're self patching, detect has to be after pt3_lib_irq_handler.s"
!src    "pt3_lib_mockingboard_detect.s"

;=============
; include song
;=============
*=(*+255)&-256 ;!align  256             ; must be on page boundary
                        ; this can be fixed but some changes would have
                        ; to be made throughout the player code
song:
;!bin "EA.PT3"
;!bin "../ootw/ootw_audio/ootw_outro.pt3"
