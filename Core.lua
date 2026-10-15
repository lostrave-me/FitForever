local name,F=...
_G.FitForever=F
F.testQueue={}; F.loading=true; F.combat=false; F.cinematic=false; F.movie=false
function F.Message(s) DEFAULT_CHAT_FRAME:AddMessage("|cff9ecb9dFitForever:|r "..F.Translate(s)) end
function F.Clock(n)
 n=math.max(0,math.ceil(n or 0)); return string.format("%02d:%02d",math.floor(n/60),n%60)
end
local function read(fn,...)
 if type(fn)~="function" then return nil end
 local args={...}
 local ok,v=pcall(function()
  local result=fn(unpack(args))
  if issecretvalue and issecretvalue(result) then return nil end
  return result and true or false
 end)
 if ok then return v end
 return nil
end
function F.InCompetitivePvP()
 if F.simPvPUntil then
  if GetTime()<F.simPvPUntil then return true end
  F.simPvPUntil=nil
 end
 if type(IsInInstance)~='function' then return nil end
 local ok,result=pcall(function()
  local _,kind=IsInInstance()
  if issecretvalue and issecretvalue(kind) then return nil end
  if type(kind)~='string' or kind=='' then return nil end
  return kind=='pvp' or kind=='arena'
 end)
 if ok then return result end
end
function F.Held(ignoreAFK)
 if F.loading or F.combat or F.cinematic or F.movie then return true end
 if F.InCompetitivePvP()~=false then return true end
 local combat=read(InCombatLockdown)
 -- Missing or restricted combat state is not permission to interrupt.
 if combat==nil or combat then return true end
 if read(UnitAffectingCombat,"player")==true or read(IsEncounterInProgress)==true then return true end
 if not ignoreAFK and read(UnitIsAFK,"player")==true then return true end
 if C_PetBattles and read(C_PetBattles.IsInBattle)==true then return true end
 return false
end
function F.ActiveRecord()
 if F.notice then return F.notice end
 if #F.testQueue>0 then return F.testQueue[1] end
 return F.engine:Ready(time())
end
function F.Status()
 if not F.engine then return "Загрузка" end
 if F.engine.paused then return "Напоминания на паузе" end
 if F.InCompetitivePvP()==true then return "На БГ и арене напоминания скрыты" end
 if #F.testQueue>0 then return "Тестовый режим" end
 if F.engine.current or #F.engine.queue>0 then return "Есть напоминание • нажми, когда удобно" end
 return "До разминки: "..F.Clock(F.engine.db.remaining.stretch)
end
function F.Draw()
 if not F.engine then return end
 if F.InCompetitivePvP()~=false then
  F.notice=nil
  local pending=F.testQueue[1] or F.engine.current
  if pending then pending.nudgedAt=nil end
  F.UI.badge:Hide();F.UI:HideReminders();return
 end
 if F.UI.movingBanner then return end
 local r=F.ActiveRecord()
 F.UI.badge:SetShown(r~=nil or #F.engine.queue>0)
 if F.Held() or F.engine.paused or (r and r.test and F.simCombatUntil and GetTime()<F.simCombatUntil) then F.UI:HideReminders(); return end
 if not r then F.shown=nil; F.UI:HideReminders(); return end
 if F.shown~=r then F.shown=r; F.UI:HideReminders() end
 if r.mode=="tucked" then F.UI:HideReminders(true); return end
 if r.mode=="card" then
  if not F.UI.card:IsShown() then F.UI:ShowCard(r) end
 else
  if not r.nudgedAt then
   r.nudgedAt=GetTime()
   if F.engine.db.settings.sound and SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then pcall(PlaySound,SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,"SFX") end
  end
  if GetTime()-r.nudgedAt>=20 then
   if r.notice then F.notice=nil;F.shown=nil;F.UI:HideReminders(true);return end
   r.mode="tucked"; F.UI:HideReminders(true)
  elseif not F.UI.nudge:IsShown() then F.UI:ShowNudge(r) end
 end
end
function F.Tuck()
 local r=F.ActiveRecord(); if r then r.mode="tucked" end; F.UI:HideReminders(true)
end
function F.Expand()
 if F.Held() or F.engine.paused then return end
 local r=F.ActiveRecord(); if not r then return end
 if r.notice then F.notice=nil;F.shown=nil;F.UI:HideReminders();F.Draw();return end
 if r.test and F.simCombatUntil and GetTime()<F.simCombatUntil then return end
 if r.id=="stretch" and not r.routine then r.routine=F.engine:Routine(); r.step=1; r.completed=0 end
 r.mode="card"; r.elapsed=r.elapsed or 0; F.UI:ShowCard(r)
end
function F.OpenPending()
 if F.ActiveRecord() then F.Expand() else F.UI:Settings() end
end
function F.Resolve(action)
 local r=F.ActiveRecord(); if not r then return end
 if r.notice then F.notice=nil
 elseif r.test then
  table.remove(F.testQueue,1)
 else
  r.opportunity=nil;r.opportunityUntil=nil;r.contextTitle=nil;r.contextBody=nil;r.flight=nil
  r.mode=nil; r.nudgedAt=nil; r.elapsed=nil; r.started=nil; r.count=nil; r.finishPlayed=nil
  if action=="later" then r.routine=nil; r.step=nil; r.completed=nil end
  F.engine:Resolve(action,time())
 end
 F.shown=nil; F.UI:HideReminders(); F.Draw()
end
function F.DoneStep()
 local r=F.ActiveRecord(); if not r then return end
 if r.routine then
  local ex=r.routine[r.step]
  r.completed=(r.completed or 0)+1
  if not r.test then F.engine.db.recent[ex.id]=time() end
  r.step=r.step+1; r.elapsed=0; r.started=nil; r.count=nil; r.finishPlayed=nil
  if r.step<=#r.routine then F.UI:ShowCard(r); return end
 end
 F.Resolve("done")
end
function F.SkipStep()
 local r=F.ActiveRecord(); if not r then return end
 if r.routine then
  r.step=r.step+1; r.elapsed=0; r.started=nil; r.count=nil; r.finishPlayed=nil
  if r.step<=#r.routine then F.UI:ShowCard(r); return end
  F.Resolve((r.completed or 0)>0 and "done" or "later")
 else F.Resolve("later") end
end
function F.SetModule(id,enabled,minutes)
 local m=F.engine.db.settings.modules[id]
 if enabled==nil then enabled=m.enabled end
 F.engine:SetModule(id,enabled,minutes)
 F.shown=nil; F.UI:HideReminders(); F.UI:RefreshSettings(); F.Draw()
end
function F.TogglePause()
 F.engine.paused=not F.engine.paused
 F.UI:HideReminders(); F.Draw()
end
function F.Test(id,ex)
 if F.UI.movingBanner then F.UI:FinishBannerMove() end
 F.notice=nil;F.testQueue={ {id=id,test=true} }; F.simCombatUntil=nil; F.simPvPUntil=nil; F.testCampUntil=nil; F.testFlightUntil=nil
 if ex then local r=F.testQueue[1]; r.routine={ex}; r.step=1; r.completed=0 end
 F.shown=nil; F.UI:HideReminders(); if F.UI.settings then F.UI.settings:Hide() end
 if F.UI.library then F.UI.library:Hide() end
 F.Draw(); F.Expand()
end
function F.TestQueue()
 F.testQueue={}
 for _,id in ipairs(F.order) do F.testQueue[#F.testQueue+1]={id=id,test=true} end
 F.simCombatUntil=nil; F.simPvPUntil=nil; F.shown=nil; F.UI:HideReminders(); F.UI.settings:Hide(); F.Draw()
 F.Message("Тест: шесть уведомлений по очереди. Реальные таймеры не изменяются. /fitforever stoptest — выйти.")
end
function F.TestCombat()
 F.Test("eyes"); F.simCombatUntil=GetTime()+8; F.UI:HideReminders()
 F.Message("Тест боя: карточка скрыта на 8 секунд, затем вернётся. Реальный бой всегда имеет приоритет.")
end
function F.TestPvP()
 F.Test('eyes');F.simPvPUntil=GetTime()+8;F.UI:HideReminders();F.Draw()
 F.Message('Тест БГ: уведомления и звуки скрыты на 8 секунд. Настоящее БГ или арена всегда имеют приоритет.')
end
function F.BeginSession()
 local d=date('*t');F.engine:BeginSession(time(),date('%Y-%m-%d'),d.hour*60+d.min)
 F.testQueue={};F.notice=nil;F.shown=nil;F.simCombatUntil=nil;F.simPvPUntil=nil
 F.testFlightUntil=nil;F.testCampUntil=nil;F.flightOffered=nil;F.flightState=nil;F.flightSample=nil;F.campAttempt=nil;F.raidBreak=nil
 if F.UI.card then F.UI:HideReminders() end
end
function F.TestSession()
 local d=date('*t');local e=F.Engine.New(F.Copy(F.engine.db),time())
 for _,id in ipairs(F.order) do if e.db.settings.modules[id].minutes then e.db.remaining[id]=0 end end
 e:BeginSession(time(),date('%Y-%m-%d'),d.hour*60+d.min)
 F.Message('Тест новой сессии: глаза — '..F.Clock(e.db.remaining.eyes)..', разминка — '..F.Clock(e.db.remaining.stretch)..', прогулка — '..F.Clock(e.db.remaining.rest)..'. Настоящие таймеры не изменены.')
end
function F.RecommendedIntervals()
 F.engine:RecommendedIntervals();F.shown=nil;F.UI:HideReminders();F.UI:RefreshSettings();F.Draw()
end
local frame=CreateFrame("Frame")
for _,event in ipairs({"ADDON_LOADED","PLAYER_LOGIN","PLAYER_LOGOUT","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","PLAYER_ENTERING_WORLD","LOADING_SCREEN_ENABLED","LOADING_SCREEN_DISABLED","CINEMATIC_START","CINEMATIC_STOP","PLAY_MOVIE","STOP_MOVIE","CHAT_MSG_RAID","CHAT_MSG_RAID_LEADER","CHAT_MSG_RAID_WARNING"}) do pcall(frame.RegisterEvent,frame,event) end
frame:SetScript("OnEvent",function(_,event,addon,sender)
 if event=="CHAT_MSG_RAID" or event=="CHAT_MSG_RAID_LEADER" or event=="CHAT_MSG_RAID_WARNING" then
  F.RaidAnnouncement(addon,sender)
 elseif event=="ADDON_LOADED" and addon==name then
  F.engine=F.Engine.New(FitForeverDB,time()); FitForeverDB=F.engine.db;F.SetLanguage(F.engine.db.settings.language)
 elseif event=="PLAYER_LOGIN" then
  if not F.engine then return end
  F.UI:Build(); F.lastTick=GetTime()
  F.ticker=C_Timer.NewTicker(1,function()
   local now=GetTime(); local delta=math.max(0,now-F.lastTick); F.lastTick=now
   local d=date("*t")
   if not F.loading then F.engine:Tick(delta,time(),read(UnitIsAFK,"player")==true,date("%Y-%m-%d"),d.hour*60+d.min)
   else F.engine.db.lastSeen=time() end
   F.CheckFlight();F.CheckRaidBreak()
   local active=F.ActiveRecord();if active and F.UI.card:IsShown() then F.UI:UpdateClock(active) end
   if not F.OnFlight() then F.CheckCamp() end
   F.Draw(); if F.UI.settings and F.UI.settings:IsShown() then F.UI:RefreshSettings() end
  end)
  F.activityTicker=C_Timer.NewTicker(.1,function()
   local now=GetTime();local delta=math.max(0,now-(F.lastActivityTick or now));F.lastActivityTick=now
   F.UpdateActivity(delta)
  end)
 elseif event=="PLAYER_LOGOUT" then
  if F.engine then F.engine.db.lastSeen=time() end
 elseif event=="PLAYER_REGEN_DISABLED" then F.combat=true;F.EndOpportunity("raid");F.raidBreak=nil
 elseif event=="PLAYER_REGEN_ENABLED" then F.combat=false
 elseif event=="PLAYER_ENTERING_WORLD" then
  F.loading=false;F.lastTick=GetTime()
  -- Event payload: isInitialLogin, isReloadingUi. Zone changes are false/false.
  if addon==true and sender~=true and not F.sessionInitialized and F.engine then F.sessionInitialized=true;F.BeginSession() end
 elseif event=="LOADING_SCREEN_DISABLED" then F.loading=false;F.lastTick=GetTime()
 elseif event=="LOADING_SCREEN_ENABLED" then F.loading=true
 elseif event=="CINEMATIC_START" then F.cinematic=true
 elseif event=="CINEMATIC_STOP" then F.cinematic=false
 elseif event=="PLAY_MOVIE" then F.movie=true
 elseif event=="STOP_MOVIE" then F.movie=false end
 if F.UI.card then F.Draw() end
end)
SLASH_FITFOREVER1="/fitforever"
SLASH_FITFOREVER2="/fitf"
SlashCmdList.FITFOREVER=function(input)
 if not F.UI.card then return end
 local cmd=(input or ""):lower():match("^%s*(.-)%s*$")
 if cmd=="stoptest" then F.notice=nil;F.testQueue={}; F.simCombatUntil=nil; F.simPvPUntil=nil; F.testFlightUntil=nil; F.shown=nil; F.UI:HideReminders(); F.Draw()
 elseif cmd=="pause" then F.TogglePause()
 elseif cmd:match("^test ") and F.defs[cmd:sub(6)] then F.Test(cmd:sub(6))
 else F.UI:Settings() end
end
