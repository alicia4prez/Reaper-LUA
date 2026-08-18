-- USER CONFIGURATION: Set the path to your template file below
-- Rea (Reaper Queen) / Alicia4preZ Reaper Script Production or Session Start
local template_path = [[C:/Your/directory/path/]]

-- 1. Open the project template first
reaper.Main_openProject(template_path)

-- 2. Set up a timer to let Reaper breathe
local start_time = reaper.time_precise()
local wait_time_seconds = 3.0 -- Increase this to 2.0 or 3.0 if your template is massive

local function process_tracks()
    -- Wait until the specified time has passed before doing anything
    if reaper.time_precise() - start_time < wait_time_seconds then
        reaper.defer(process_tracks)
        return
    end

    local num_tracks = reaper.CountTracks(0)
    
    if num_tracks == 0 then
        reaper.ShowMessageBox("Script finished, but no tracks were found.", "Notice", 0)
        return
    end

    for i = 0, num_tracks - 1 do
        local track = reaper.GetTrack(0, i)
        
        -- THE CRASH PREVENTER: Make absolutely sure the track exists in memory before touching it
        if track ~= nil then
            -- Set fader to unity gain (1.0 = 0dB)
            reaper.SetMediaTrackInfo_Value(track, "D_VOL", 1.0)
            
            -- Set pan to center (0.0)
            reaper.SetMediaTrackInfo_Value(track, "D_PAN", 0.0)
            
            -- Check folder depth to identify child tracks
            local folder_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
            
            if folder_depth <= 0 then
                local parent = reaper.GetParentTrack(track)
                if parent then
                    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1.0)
                end
            end
        end
    end
    
    -- Tell Reaper to update the interface so you see the changes
    reaper.TrackList_AdjustWindows(false)
    reaper.UpdateArrange()
end

-- Start the processing loop
reaper.defer(process_tracks)
