---------------------------------------------------------------------------------
-- 
-- Arcade: Green Beret (Rush'n Attack)  port to MiSTer by MiSTer-X
-- 04 November 2019
-- 
---------------------------------------------------------------------------------
-- FPGA Mr.GOEMON for XILINX Spartan-6
------------------------------------------------
-- Copyright (c) 2013 MiSTer-X
---------------------------------------------------------------------------------
-- T80/T80s - Version : 0247
------------------------------
-- Z80 compatible microprocessor core
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
---------------------------------------------------------------------------------
-- 
-- 
-- Keyboard inputs :
--
--   F2          : Coin + Start 2 players
--   F1          : Coin + Start 1 player
--   UP,DOWN,LEFT,RIGHT arrows : Movements
--   SPACE       : Trig1
--   Ctrl        : Trig2
--
-- MAME/IPAC/JPAC Style Keyboard inputs:
--   5           : Coin 1
--   6           : Coin 2
--   1           : Start 1 Player
--   2           : Start 2 Players
--   R,F,D,G     : Player 2 Movements
--   A           : Trig1
--   S           : Trig2
--
-- Joystick support.
-- 
--
---------------------------------------------------------------------------------
-- 06 Nov.2019 : Fixed V-Sync frequency
---------------------------------------------------------------------------------
-- 18 Nov.2019 : Fixed sprite issue
--               Added ROM build scripts for "Rush'n Attack"
---------------------------------------------------------------------------------

                                *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip

