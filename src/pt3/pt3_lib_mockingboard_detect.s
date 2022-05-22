;===================================================================
; code to detect mockingboard
;===================================================================
; this isn't always easy
; my inclination is to just assume slot #4 but that isn't always realistic

; code below based on "hw.mockingboard.a" from "Total Replay"

;license:MIT
; By Andrew Roughan
;   in the style of 4am for Total Replay
;
; Mockingboard support functions
;

;------------------------------------------------------------------------------
; HasMockingboard
; detect Mockingboard card by searching for 6522 timers across all slots
; access 6522 timers with deterministic cycle counts
;
;   based on prior art in Mockingboard Developers Toolkit
;   with optimisation from deater/french touch
;   also takes into account FastChip //e clock difference
;
; in:    none
;        accelerators should be off
; out:   C set if Mockingboard found in any slot
;        if card was found, X = #$Cn where n is the slot number of the card
;        C clear if no Mockingboard found
;        other flags clobbered
;        zp $65-$67 clobbered
;        A/Y clobbered
;------------------------------------------------------------------------------

mockingboard_detect:

        ; activate IIc mockingboard?
        ; this might only be necessary to allow detection
        ; I get the impression the Mockingboard 4c activates
        ; when you access any of the 6522 ports in Slot 4

!ifdef PT3_ENABLE_APPLE_IIC {
        jsr     detect_appleii_model
        lda     APPLEII_MODEL
        cmp     #'C'
        bne     not_iic

        lda     #$ff

        ; don't bother patching these, IIc mockingboard always slot 4?

        sta     MOCK_6522_DDRA1
        sta     MOCK_6522_T1CL
}

not_iic:
        lda     #$00
        sta     MB_ADDR_L
        ldx     #$C7                    ; start at slot #7
mb_slot_loop:
        stx     MB_ADDR_H
        ldy     #$04                    ; 6522 #1 $Cx04
        jsr     mb_timer_check
        bne     mb_next_slot
        ldy     #$84                    ; 6522 #2 $Cx84
        jsr     mb_timer_check
        bne     mb_next_slot
mb_found:
        sec                             ; found
        rts

mb_next_slot:
        dex
        cpx     #$C0
        bne     mb_slot_loop

        clc                             ; not found
        rts

mb_timer_check:
        lda     (MB_ADDR_L),Y           ; read 6522 timer low byte
        sta     MB_VALUE
        lda     (MB_ADDR_L),Y           ; second time
        sec
        sbc     MB_VALUE
        cmp     #$F8                    ; looking for (-)8 cycles between reads
        beq     mb_timer_check_done
        cmp     #$F7                    ; FastChip //e clock is different
mb_timer_check_done:
        rts



;===================================================================
; code to patch mockingboard if not in slot#4
;===================================================================
mockingboard_patch:

        lda     MB_ADDR_H

        sta     pt3_irq_smc1+2          ; 1

        sta     pt3_irq_smc2+2          ; 2
        sta     pt3_irq_smc2+5          ; 3

        sta     pt3_irq_smc3+2          ; 4
        sta     pt3_irq_smc3+5          ; 5

        sta     pt3_irq_smc4+2          ; 6
        sta     pt3_irq_smc4+5          ; 7

        sta     pt3_irq_smc5+2          ; 8
        sta     pt3_irq_smc5+5          ; 9

        sta     pt3_irq_smc6+2          ; 10
        sta     pt3_irq_smc6+5          ; 11

        sta     pt3_irq_smc7+2          ; 12
        sta     pt3_irq_smc7+5          ; 13

        sta     mock_init_smc1+2        ; 14
        sta     mock_init_smc1+5        ; 15

        sta     mock_init_smc2+2        ; 16
        sta     mock_init_smc2+5        ; 17

        sta     reset_ay_smc1+2         ; 18
        sta     reset_ay_smc2+2         ; 19
        sta     reset_ay_smc3+2         ; 20
        sta     reset_ay_smc4+2         ; 21

        sta     write_ay_smc1+2         ; 22
        sta     write_ay_smc1+5         ; 23

        sta     write_ay_smc2+2         ; 24
        sta     write_ay_smc2+5         ; 25

        sta     write_ay_smc3+2         ; 26
        sta     write_ay_smc3+5         ; 27

        sta     write_ay_smc4+2         ; 28
        sta     write_ay_smc4+5         ; 29

        sta     write_ay_smc5+2         ; 30
        sta     write_ay_smc5+5         ; 31

        sta     write_ay_smc6+2         ; 32
        sta     write_ay_smc6+5         ; 33

        sta     setup_irq_smc1+2        ; 34
        sta     setup_irq_smc2+2        ; 35
        sta     setup_irq_smc3+2        ; 36
        sta     setup_irq_smc4+2        ; 37
        sta     setup_irq_smc5+2        ; 38
        sta     setup_irq_smc6+2        ; 39

        rts
