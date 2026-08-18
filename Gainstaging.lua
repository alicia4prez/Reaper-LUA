-- @description Real-Time Gain Staging Assistant & Monitor
-- @author Rea (Reaper Queen) / Alicia4preZ
-- @version 1.4

if not reaper.ImGui_CreateContext then
    reaper.ShowMessageBox("ReaImGui extension is required. Please install it via ReaPack.", "Missing Dependency", 0)
    return
end

local ctx = reaper.ImGui_CreateContext("Gain Staging Assistant")
local target_db = -18.0

local function run()
    local visible, open = reaper.ImGui_Begin(ctx, "Gain Staging Assistant", true, reaper.ImGui_WindowFlags_AlwaysAutoResize())

    if visible then
        reaper.ImGui_Text(ctx, "Real-Time Track Meter & Gain Stager")
        reaper.ImGui_Separator(ctx)

        _, target_db = reaper.ImGui_SliderDouble(ctx, "Target Level (dBFS)", target_db, -30.0, -6.0, "%.1f dB")
        
        reaper.ImGui_Spacing(ctx)
        reaper.ImGui_Text(ctx, "Selected Tracks Live Status:")
        reaper.ImGui_Separator(ctx)

        local num_selected = reaper.CountSelectedTracks(0)
        if num_selected == 0 then
            reaper.ImGui_TextColored(ctx, 0xFF6666FF, "No tracks selected! Select tracks to monitor.")
        else
            for i = 0, num_selected - 1 do
                local track = reaper.GetSelectedTrack(0, i)
                local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
                if track_name == "" then track_name = string.format("Track %d", i + 1) end

                local peak_l = reaper.Track_GetPeakInfo(track, 0)
                local peak_r = reaper.Track_GetPeakInfo(track, 1)
                local max_peak = math.max(peak_l, peak_r)
                
                local peak_db = -150.0
                if max_peak > 0.00001 then
                    peak_db = 20 * math.log(max_peak, 10)
                end

                reaper.ImGui_Text(ctx, string.format("%s: %.1f dBFS", track_name, peak_db))
                
                reaper.ImGui_SameLine(ctx)
                if peak_db > (target_db + 3) then
                    reaper.ImGui_TextColored(ctx, 0x0055FFFF, "[Too Hot]") 
                elseif peak_db < (target_db - 8) and peak_db > -100 then
                    reaper.ImGui_TextColored(ctx, 0xFFFF00FF, "[Too Low]") 
                elseif peak_db <= -100 then
                    reaper.ImGui_TextColored(ctx, 0x888888FF, "[Silence]")
                else
                    reaper.ImGui_TextColored(ctx, 0x00FF00FF, "[Optimal]") 
                end
            end

            reaper.ImGui_Spacing(ctx)
            reaper.ImGui_Separator(ctx)

            if reaper.ImGui_Button(ctx, "Auto-Align Selected Tracks to Target") then
                reaper.Undo_BeginBlock()
                for i = 0, num_selected - 1 do
                    local track = reaper.GetSelectedTrack(0, i)
                    local peak_l = reaper.Track_GetPeakInfo(track, 0)
                    local peak_r = reaper.Track_GetPeakInfo(track, 1)
                    local max_peak = math.max(peak_l, peak_r)
                    
                    if max_peak > 0.00001 then
                        local current_db = 20 * math.log(max_peak, 10)
                        local diff_db = target_db - current_db
                        local current_vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
                        local current_vol_db = reaper.SLIDER2DB(current_vol)
                        local new_vol_db = current_vol_db + diff_db
                        local new_linear_vol = reaper.DB2SLIDER(new_vol_db)
                        
                        reaper.SetMediaTrackInfo_Value(track, "D_VOL", new_linear_vol)
                    end
                end
                reaper.Undo_EndBlock("Auto-Align Gain Staging for Selected Tracks", -1)
            end
        end

        reaper.ImGui_End(ctx)
    end

    if open then
        reaper.defer(run)
    end
end

reaper.defer(run)
