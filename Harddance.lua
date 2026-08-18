-- @description Hard Dance & Euro-Trance 145 BPM Template Generator
-- @author Rea (Reaper Queen) \ Alicia4preZ
-- @version 1.1
-- @about Automatically creates a structured 145 BPM project with a Drums folder, Kick track, Snare track, Bass track (with sidechain setup), and Synth bus.

function create_hard_dance_template()
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)

    -- 1. Set Project Tempo to 145 BPM cleanly
    -- Parameters: (proj, addandeol, bpm, timesig_num, timesig_denom)
    reaper.SetCurrentBPM(0, 145.0, true)

    -- 2. Create Tracks
    -- Track 1: Drums Folder
    reaper.InsertTrackAtIndex(0, true)
    local tr_drums_folder = reaper.GetTrack(0, 0)
    reaper.GetSetMediaTrackInfo_String(tr_drums_folder, "P_NAME", "[FOLDER] Drums", true)
    reaper.SetMediaTrackInfo_Value(tr_drums_folder, "I_FOLDERDEPTH", 1) -- Start folder

    -- Track 2: Kick (Sidechain Source)
    reaper.InsertTrackAtIndex(1, true)
    local tr_kick = reaper.GetTrack(0, 1)
    reaper.GetSetMediaTrackInfo_String(tr_kick, "P_NAME", "Kick (Sidechain Src)", true)

    -- Track 3: Snare / Claps
    reaper.InsertTrackAtIndex(2, true)
    local tr_snare = reaper.GetTrack(0, 2)
    reaper.GetSetMediaTrackInfo_String(tr_snare, "P_NAME", "Snare / Claps", true)

    -- Track 4: Percussion / Hats
    reaper.InsertTrackAtIndex(3, true)
    local tr_percs = reaper.GetTrack(0, 3)
    reaper.GetSetMediaTrackInfo_String(tr_percs, "P_NAME", "Percussion & Hats", true)
    reaper.SetMediaTrackInfo_Value(tr_percs, "I_FOLDERDEPTH", -1) -- End Drums folder

    -- Track 5: Bass Folder / Bus (Where ZL Equalizer 2 lives)
    reaper.InsertTrackAtIndex(4, true)
    local tr_bass_folder = reaper.GetTrack(0, 4)
    reaper.GetSetMediaTrackInfo_String(tr_bass_folder, "P_NAME", "[FOLDER] Bass & Low End", true)
    reaper.SetMediaTrackInfo_Value(tr_bass_folder, "I_FOLDERDEPTH", 1) -- Start folder

    -- Track 6: Sub / Mid Bass
    reaper.InsertTrackAtIndex(5, true)
    local tr_bass = reaper.GetTrack(0, 5)
    reaper.GetSetMediaTrackInfo_String(tr_bass, "P_NAME", "Sub/Mid Bass (ZL Eq 2)", true)
    reaper.SetMediaTrackInfo_Value(tr_bass, "I_FOLDERDEPTH", -1) -- End Bass folder

    -- Track 7: Synths / Leads Bus
    reaper.InsertTrackAtIndex(6, true)
    local tr_synths = reaper.GetTrack(0, 6)
    reaper.GetSetMediaTrackInfo_String(tr_synths, "P_NAME", "[BUS] 90s Supersaws & Leads", true)

    -- 3. Setup Sidechain Routing (Kick to Bass: Channels 1/2 -> 3/4)
    local send_idx = reaper.CreateTrackSend(tr_kick, tr_bass)
    
    -- Configure send to use auxiliary channels 3/4 on the destination track
    reaper.SetTrackSendInfo_Value(tr_bass, 0, send_idx, "I_SRCCHAN", 0)   -- Source Ch 1/2
    reaper.SetTrackSendInfo_Value(tr_bass, 0, send_idx, "I_DSTCHAN", 2)   -- Dest Ch 3/4 (0-indexed: 2 means channel 3)
    reaper.SetTrackSendInfo_Value(tr_bass, 0, send_idx, "I_AUDIO_FLAG", 0) -- Send audio

    reaper.PreventUIRefresh(0)
    reaper.UpdateArrange()
    reaper.Undo_EndBlock("Generate Hard Dance 145 BPM Template", -1)
    
    reaper.ShowMessageBox("Hard Dance 145 BPM template generated successfully! Kick-to-Bass sidechain routing for channels 3/4 is locked in.", "Template Ready", 0)
end

create_hard_dance_template()
