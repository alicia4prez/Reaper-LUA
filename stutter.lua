-- @description EDM Vocal Rhythm Chopper & Stutter Grid
-- @author Rea (Reaper Queen) \ Alicia4preZ
-- @version 1.0
-- @about Chops a selected audio loop into strict rhythmic grid slices (16th notes) for EDM/Stutter House textures.

function chop_vocal_rhythm()
    local item = reaper.GetSelectedMediaItem(0, 0)
    if not item then
        reaper.ShowMessageBox("Please select a vocal audio item to chop.", "EDM Chopper Error", 0)
        return
    end

    local take = reaper.GetActiveTake(item)
    if not take or reaper.TakeIsMIDI(take) then
        reaper.ShowMessageBox("Selected item must be an audio track.", "Error", 0)
        return
    end

    reaper.Undo_BeginBlock()

    -- Get item start and end position
    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local item_end = item_start + item_length

    -- Get current project tempo and calculate 16th note length in seconds
    local tempo = reaper.Master_GetTempo()
    local beat_len = 60.0 / tempo
    local step_len = beat_len / 4.0 -- 16th note division

    local track = reaper.GetMediaItemTrack(item)
    
    -- Current split cursor starting from item start + one step
    local current_pos = item_start + step_len
    
    -- Loop through the item and split it at every 16th note interval
    while current_pos < item_end - 0.001 do
        -- Split the media item at current_pos
        local new_item = reaper.SplitMediaItem(item, current_pos)
        if new_item then
            -- Update reference to the remaining active item for subsequent splits
            item = new_item 
        end
        current_pos = current_pos + step_len
    end

    -- Now, apply tiny 5ms crossfades to every resulting slice on the track to prevent clicks
    local num_items = reaper.CountTrackMediaItems(track)
    for i = 0, num_items - 1.0 do
        local tr_item = reaper.GetTrackMediaItem(track, i)
        if tr_item then
            -- Set automatic fade in/out length to 0.005 seconds (5ms)
            reaper.SetMediaItemInfo_Value(tr_item, "D_FADEINLEN", 0.005)
            reaper.SetMediaItemInfo_Value(tr_item, "D_FADEOUTLEN", 0.005)
        end
    end

    reaper.UpdateArrange()
    reaper.Undo_EndBlock("EDM Vocal Rhythm Chop (16th Grid)", -1)
    
    reaper.ShowMessageBox("Vocal chopped into clean 16th-note stutter slices with anti-click fades!", "EDM Chopper Success", 0)
end

chop_vocal_rhythm()
