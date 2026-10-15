local _,F=...
local function visible(v) return not issecretvalue or not issecretvalue(v) end
-- Travelcraft's named bar is public; its addon namespace is private.
-- Verify a decreasing clock: unknown routes display elapsed time instead.
function F.FlightRemaining()
 if F.testFlightUntil then return math.max(0,F.testFlightUntil-GetTime()),'тест' end
 local ok,left=pcall(function()
  local b=_G.TravelcraftFlightBar
  if not b or not b:IsShown() or not b.time then return end
  local t=b.time:GetText();if not visible(t) or type(t)~='string' then return end
  local m,s=t:match('^~?(%d+):(%d%d)$');m,s=tonumber(m),tonumber(s)
  if not m or s>59 then return end
  return m*60+s
 end)
 if not ok or not left then F.flightSample=nil;return end
 local previous=F.flightSample
 local now=GetTime()
 local verified=previous and now-previous.at<=3 and
  ((left<previous.left and previous.left-left<=now-previous.at+2) or (left==previous.left and previous.verified))
 F.flightSample={left=left,at=now,verified=verified}
 if verified then return left,'Travelcraft' end
end
function F.OpportunityChoice(left)
 local e=F.engine
 local ids=(left and left>300) and {'water','meal','snack','rest','eyes','stretch'} or {'eyes','stretch'}
 local required={water=90,meal=300,snack=120,rest=300,eyes=20,stretch=15}
 for _,id in ipairs(ids) do
  local fits=not left or left>=required[id]+(left>300 and 60 or 10)
  if fits and e.db.settings.modules[id].enabled and (tonumber(e.db.snoozes[id]) or 0)<=time() then
   local r=e.current and e.current.id==id and e.current
   if not r then for _,q in ipairs(e.queue) do if q.id==id then r=q;break end end end
   if r then return r end
  end
 end
end
function F.ApplyOpportunity(r,kind,left)
 local e=F.engine
 if e.current~=r then
  if e.current then e.queue[#e.queue+1]=e.current end
  for i=#e.queue,1,-1 do if e.queue[i]==r then table.remove(e.queue,i) end end
  e.current=r
 end
 if r.id=='stretch' then r.routine={F.exercises[1]};r.step=1;r.completed=0 end
 r.opportunity=kind;r.opportunityUntil=left and GetTime()+left or nil
 r.flight=kind=='flight';r.camp=nil;r.mode=kind=='flight' and 'card' or nil;r.nudgedAt=nil
 r.contextTitle=nil;r.contextBody=nil
 if left and left>300 then
  if r.id=='water' then r.contextTitle='Пройдись за водой';r.contextBody='Есть время наполнить флягу и немного пройтись. Попей, если хочется. Вернись с запасом до окончания паузы.'
  elseif r.id=='meal' or r.id=='snack' then r.contextTitle='Удобный момент для перекуса';r.contextBody='Напоминание о еде уже подошло. Если голоден, можно взять йогурт, фрукт или другой привычный перекус. Не обязательно есть только из-за перелёта.' end
 end
 F.shown=nil
 if kind=='flight' then F.Expand() end
end
function F.ReturnSignal(kind)
 if F.InCompetitivePvP()~=false then return end
 if not F.engine.db.settings.returnSound then return end
 if type(PlaySound)=='function' then pcall(PlaySound,SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959,'Master') end
 F.notice={id='rest',notice=true,contextTitle=kind=='flight' and 'Скоро посадка' or 'Перерыв заканчивается',contextBody='Осталось примерно 60 секунд. Возвращайся к игре.',nudgedAt=GetTime()}
 F.shown=nil;F.Draw()
end
function F.EndOpportunity(kind)
 local r=F.engine and F.engine.current
 if r and r.opportunity==kind then
  r.opportunity=nil;r.opportunityUntil=nil;r.contextTitle=nil;r.contextBody=nil;r.flight=nil;r.started=false;r.mode='tucked'
  F.shown=nil;F.UI:HideReminders()
 end
end
function F.CheckFlight()
 local flying=F.OnFlight();if flying==nil then return end
 if not flying then
  F.flightOffered=nil;F.flightSample=nil;F.flightState=nil
  F.EndOpportunity('flight')
  local r=F.ActiveRecord();if r and r.flight then r.flight=nil;r.started=false;r.mode='tucked';F.shown=nil;F.UI:HideReminders() end
  F.UI:FlightMode(false);return
 end
 local left=F.FlightRemaining()
 local state=F.flightState or {};F.flightState=state
 if left and state.last and state.last>60 and left<=60 and not state.signalled and F.engine.db.settings.flights then
  state.signalled=true;F.ReturnSignal('flight')
 end
 state.last=left or state.last
 local current=F.engine.current
 if current and current.opportunity=='flight' then current.opportunityUntil=left and GetTime()+left or nil end
 if not F.engine.db.settings.flights or F.flightOffered or #F.testQueue>0 or F.engine.paused or F.Held() or F.notice then return end
 if current and (current.mode=='card' or current.started) then return end
 -- Give the countdown two ticks to distinguish remaining and elapsed time.
 if not left and F.flightSample and not state.waited then state.waited=true;return end
 local chosen=F.OpportunityChoice(left);if not chosen then return end
 F.flightOffered=true;F.ApplyOpportunity(chosen,'flight',left)
end
local function lower(text)
 -- Lua's string.lower does not lowercase UTF-8 Cyrillic.
 text=text:gsub('[A-Z]',function(c) return c:lower() end)
 local upper={'П','Е','Р','Ы','В','Н','А','М','И','У','Т','О','К','Ч','С','З','Ш','Л','Д','Б','Г','Ж','Ь','Я','Ю','Ц','Щ','Э','Ф','Х','Й','Ё'}
 local low={'п','е','р','ы','в','н','а','м','и','у','т','о','к','ч','с','з','ш','л','д','б','г','ж','ь','я','ю','ц','щ','э','ф','х','й','ё'}
 for i,c in ipairs(upper) do text=text:gsub(c,low[i]) end
 return text:match('^%s*(.-)%s*$')
end
function F.ParseBreak(text)
 if type(text)~='string' or #text>500 then return end
 text=lower(text)
 if text:match('^перерыв окончен') or text:match('^перерыв закончен') or text:match('^break over') or text:match('^break ended') then return 0 end
 local tail=text:match('^перерыв%s+(.+)') or text:match('^break%s+(.+)')
 if not tail then return end
 tail=tail:gsub('^на%s+',''):gsub('^for%s+','')
 local m,s=tail:match('^(%d+):(%d%d)');local seconds
 if m and tonumber(s)<60 then seconds=tonumber(m)*60+tonumber(s)
 else
  local n,unit=tail:match('^(%d+)%s*(.+)')
  if n and (unit:match('^мин') or unit:match('^min')) then seconds=tonumber(n)*60
  elseif n and (unit:match('^сек') or unit:match('^sec')) then seconds=tonumber(n) end
 end
 if seconds and seconds>=15 and seconds<=3600 then return seconds end
end
function F.RaidAnnouncement(message,sender)
 if F.InCompetitivePvP()~=false then return end
 if not F.engine or not F.engine.db.settings.raidBreaks then return end
 local ok,authorized=pcall(function()
  if not IsInRaid or not IsInRaid() then return false end
  for i=1,(MAX_RAID_MEMBERS or 40) do
   local name,rank=GetRaidRosterInfo(i)
   if visible(name) and visible(rank) and type(name)=='string' and type(rank)=='number' and rank>0 then
    local match=name==sender
    if not name:find('-',1,true) and type(sender)=='string' then
     local realm=GetNormalizedRealmName and GetNormalizedRealmName()
     match=match or (realm and sender==name..'-'..realm)
    end
    if match then return true end
   end
  end
  return false
 end)
 if not ok or not authorized then return end
 if not visible(message) or not visible(sender) then return end
 local duration=F.ParseBreak(message);if duration==nil then return end
 if duration>0 and F.raidBreak and F.raidBreak.message==message and GetTime()-F.raidBreak.received<10 then return end
 F.EndOpportunity('raid');F.raidBreak=nil
 if duration>0 then F.raidBreak={untilTime=GetTime()+duration,message=message,received=GetTime()} end
end
function F.CheckRaidBreak()
 local state=F.raidBreak;if not state then return end
 if F.InCompetitivePvP()~=false then F.EndOpportunity('raid');F.raidBreak=nil;return end
 local ok,inRaid=pcall(function() return IsInRaid and IsInRaid() end)
 local left=state.untilTime-GetTime()
 if left<=0 or F.combat or (not state.test and (not ok or not inRaid)) then
  F.EndOpportunity('raid');F.raidBreak=nil;return
 end
 if state.last and state.last>60 and left<=60 and not state.signalled then state.signalled=true;F.ReturnSignal('raid') end
 state.last=left
 if state.offered or F.engine.paused or F.Held() or F.OnFlight() or #F.testQueue>0 or F.notice then return end
 local current=F.engine.current
 if current and (current.mode=='card' or current.started) then return end
 local r=F.OpportunityChoice(left)
 if r then state.offered=true;F.ApplyOpportunity(r,'raid',left) end
end
function F.TestOpportunity(kind)
 if kind=='signal' then F.ReturnSignal('flight');if F.UI.settings then F.UI.settings:Hide() end;return end
 F.Test(kind=='long' and 'water' or 'eyes')
 local r=F.testQueue[1];r.opportunity=kind=='raid' and 'raid' or 'flight';r.opportunityUntil=GetTime()+600
 r.flight=kind~='raid'
 if r.flight then F.testFlightUntil=r.opportunityUntil end
 if kind=='long' then r.contextTitle='Пройдись за водой';r.contextBody='Тест длинного полёта: можно наполнить флягу, пройтись и попить, если хочется.' end
 F.UI:ShowCard(r)
end
