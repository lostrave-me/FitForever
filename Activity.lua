local _,F=...
local function public(value) return not issecretvalue or not issecretvalue(value) end
function F.Identity()
 local ok,race,gender,faction,label=pcall(function()
  local localized,token=UnitRace('player'); local sex=UnitSex('player'); local side=UnitFactionGroup('player')
  if not public(token) or not public(sex) or not public(side) or not public(localized) then return end
  if type(token)~='string' or type(side)~='string' then return end
  local tag=token:lower():gsub('%s',''); if tag=='scourge' then tag='undead' end
  return tag,sex==3 and 'female' or sex==2 and 'male' or nil,side:lower(),localized
 end)
 if ok then return race,gender,faction,label end
end
function F.ShoulderTexture(phase)
 local race,gender,faction=F.Identity()
 local key=race and gender and faction and (race..'_'..gender..'_'..faction)
 local stem=key and F.shoulderArt[key]
 if stem then return 'Interface\\AddOns\\FitForever\\Media\\'..stem..'_'..phase..'.tga',true end
 return 'Interface\\AddOns\\FitForever\\Media\\shoulders.tga',false
end
function F.ExerciseTexture(id,phase)
 if id=='shoulders' then return F.ShoulderTexture(phase) end
 local race,sex,side=F.Identity()
 if race=='skyborne' then side='neutral' end
 local key=race and sex and side and (race..'_'..sex..'_'..side)
 local stem=key and F.exerciseArt[id] and F.exerciseArt[id][key]
 if stem then return 'Interface\\AddOns\\FitForever\\Media\\'..stem..'_'..phase..'.tga',true end
 return 'Interface\\AddOns\\FitForever\\Media\\'..id..'.tga',false
end
function F.ExerciseFrame(r)
 local ex=r.routine and r.routine[r.step];if not ex then return end
 local elapsed=r.elapsed or 0
 if ex.id=='shoulders' then return elapsed<15 and elapsed%5>=1 and elapsed%5<4 and 2 or 1 end
 if ex.id=='hands' then return elapsed<12 and elapsed%4>=1 and elapsed%4<3 and 2 or 1 end
 if ex.id=='neck' then
  if elapsed>=42 then return 1 end
  local slot=math.floor(elapsed/7);local within=elapsed%7
  if within>=1 and within<6 then return slot%2==0 and 2 or 3 end
  return 1
 end
 return 1
end
function F.Activity(r)
 local ex=r.routine and r.routine[r.step]
 if ex then
  if ex.id=='shoulders' then return 'timed',15,ex end
  if ex.id=='hands' then return 'timed',12,ex end
  if ex.id=='neck' then return 'timed',42,ex end
  return 'count',F.exerciseCounts[ex.id] or 1,ex
 end
 if F.defs[r.id].seconds then return 'timed',F.defs[r.id].seconds end
 return 'confirm',1
end
function F.StartActivity()
 local r=F.ActiveRecord(); if not r then return end
 local kind,total=F.Activity(r)
 if kind=='timed' then
  if (r.elapsed or 0)>=total then r.elapsed=0; r.finishPlayed=nil end
  r.started=not r.started
 elseif kind=='count' then
  r.count=math.min(total,(r.count or 0)+1)
  if r.count==total then F.FinishSignal(r) end
 end
 F.UI:UpdateClock(r)
end
function F.FinishSignal(r)
 if F.InCompetitivePvP()~=false then return end
 if r.finishPlayed then return end
 r.finishPlayed=true
 if F.engine.db.settings.finishSound and type(PlaySound)=='function' then
  -- Numeric SOUNDKIT fallback: RAID_WARNING, present in the client sound kit.
  pcall(PlaySound,SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959,'Master')
 end
end
function F.UpdateActivity(delta)
 local r=F.ActiveRecord(); if not r or not r.started then return end
 if F.engine.paused or F.Held(true) or (r.test and F.simCombatUntil and GetTime()<F.simCombatUntil) then return end
 local kind,total=F.Activity(r)
 if kind~='timed' then return end
 r.elapsed=math.min(total,(r.elapsed or 0)+math.min(delta,2))
 if r.elapsed>=total then r.started=false;F.FinishSignal(r) end
 if F.UI.card:IsShown() then F.UI:UpdateClock(r) end
end
function F.CampRemaining()
 if F.testCampUntil then return math.max(0,F.testCampUntil-GetTime()),'test' end
 if F.Held(true) or not C_UnitAuras or type(C_UnitAuras.GetAuraDataByIndex)~='function' then return end
 local ok,remaining,key=pcall(function()
  for i=1,80 do
   local a=C_UnitAuras.GetAuraDataByIndex('player',i,'HELPFUL');if not a then break end
   if public(a.spellId) and a.spellId==1229739 and public(a.expirationTime) and type(a.expirationTime)=='number' then
    return math.max(0,a.expirationTime-GetTime()),a.expirationTime
   end
  end
 end)
 if ok then return remaining,key end
end
function F.CheckCamp()
 if not F.engine.db.settings.campfire or #F.testQueue>0 or F.engine.paused or F.Held() then return end
 local left,key=F.CampRemaining()
 if not left or left<=0 then F.campAttempt=nil;return end
 if F.campAttempt==key then return end
 local e=F.engine
 local current=e.current
 if current and (current.mode=='card' or current.started) then return end
 local function due(id)
  if not e.db.settings.modules[id].enabled then return end
  if e.db.remaining[id]>0 or (tonumber(e.db.snoozes[id]) or 0)>time() then return end
  if current and current.id==id then return current end
  for _,q in ipairs(e.queue) do if q.id==id then return q end end
 end
 local r
 if left>=22 then r=due('eyes') end
 if not r and left>=17 then r=due('stretch') end
 if not r then return end
 F.campAttempt=key
 if current~=r then
  if current then e.queue[#e.queue+1]=current end
  for i=#e.queue,1,-1 do if e.queue[i]==r then table.remove(e.queue,i) end end
  e.current=r
 end
 if r.id=='stretch' then r.routine={F.exercises[1]};r.step=1;r.completed=0 end
 r.camp=true;r.campUntil=GetTime()+left;r.mode=nil;r.nudgedAt=nil
 F.shown=nil
end
function F.TestCamp()
 F.Test('eyes');local r=F.testQueue[1];r.camp=true;r.campUntil=GetTime()+60
 F.UI:ShowCard(r)
end

function F.OnFlight()
 if F.testFlightUntil then
  if GetTime()<F.testFlightUntil then return true end
  F.testFlightUntil=nil;return false
 end
 if type(UnitOnTaxi)~='function' then return nil end
 local ok,value=pcall(function()
  local result=UnitOnTaxi('player')
  if not public(result) then return nil end
  return result and true or false
 end)
 if ok then return value end
end
function F.TestFlight()
 F.Test('stretch',F.exercises[1]);F.testFlightUntil=GetTime()+30
 local r=F.testQueue[1];r.flight=true;F.UI:ShowCard(r)
end
