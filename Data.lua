local _, F = ...
F.order = {"rest", "stretch", "eyes", "water", "meal", "snack"}
F.defs = {
 stretch={title="Разминка", minutes=30, enabled=true, body="Короткая разминка для смены положения.", icon="Interface\\Icons\\Ability_Druid_Dash"},
 eyes={title="Отдых для глаз", minutes=20, enabled=true, body="Посмотри вдаль примерно на 6 метров в течение 20 секунд. Не следи за таймером на экране.", seconds=20, icon="Interface\\Icons\\Spell_Holy_MindVision"},
 rest={title="Пора пройтись", minutes=60, enabled=true, body="Отойди от экрана, встань и немного походи. Ориентир — 5–10 минут; выбери удобную длительность.", seconds=300, icon="Interface\\Icons\\Ability_Tracking"},
 water={title="Пауза для воды", minutes=60, enabled=true, body="Не забыл попить? Сделай паузу для воды, если хочется пить. Объём выбирай по своим потребностям — обязательной нормы за час нет.", icon="Interface\\Icons\\INV_Drink_18"},
 meal={title="Время поесть", enabled=false, body="Подошло выбранное тобой время еды. Можно завершить текущие дела и поесть вдали от экрана.", icon="Interface\\Icons\\INV_Misc_Food_19"},
 snack={title="Не проголодался?", minutes=180, enabled=false, body="Если хочется есть, сделай паузу на перекус: например, йогурт с ягодами или овощи с хумусом. Перекус не обязателен.", icon="Interface\\Icons\\INV_Misc_Food_57"},
}
F.exercises = {
 {id="shoulders", title="Подними и расслабь плечи", dose="3 раза • удерживай 3 секунды", text="Медленно подними плечи к ушам. Задержись на 3 секунды и расслабь, опуская плечи. Голова остаётся прямо, руки свободны.", art="shoulders", source="CCOHS — Office Ergonomics: Stretching"},
 {id="hands", title="Раскрой кисти", dose="3 раза обеими руками", text="Мягко сожми кисти в кулаки, затем раскрой ладони и расправь пальцы. Не сжимай с усилием, запястья держи свободно.", art="hands", source="Newcastle Hospitals NHS — 1 minute body check"},
 {id="neck", title="Повороты головы", dose="3 раза в каждую сторону • по 5 секунд", text="Сядь прямо, опусти плечи. Медленно поверни голову влево в комфортных пределах, задержись на 5 секунд и вернись. Повтори вправо. Не запрокидывай голову.", art="neck", source="NHS — Sitting exercises"},
 {id="ankles", title="Движения стопами", dose="2 подхода по 5 каждой стопой", text="На устойчивом стуле без колёс выпрями и слегка приподними одну ногу. Плавно направляй носок от себя и к себе. Затем смени ногу. Если стул неустойчив, пропусти упражнение.", art="ankles", source="NHS — Sitting exercises"},
}

F.exerciseCounts={shoulders=3,hands=3,neck=6,ankles=20}
F.shoulderArt={}
F.shoulderArt["bloodelf_male_horde"]="shoulders_bloodelf_male_horde"
F.shoulderArt["dwarf_female_alliance"]="shoulders_dwarf_female_alliance"
F.shoulderArt["dwarf_male_alliance"]="shoulders_dwarf_male_alliance"
F.shoulderArt["gnome_female_alliance"]="shoulders_gnome_female_alliance"
F.shoulderArt["gnome_male_alliance"]="shoulders_gnome_male_alliance"
F.shoulderArt["human_female_alliance"]="shoulders_human_female_alliance"
F.shoulderArt["human_male_alliance"]="shoulders_human_male_alliance"
F.shoulderArt["nightelf_female_alliance"]="shoulders_nightelf_female_alliance"
F.shoulderArt["nightelf_male_alliance"]="shoulders_nightelf_male_alliance"
F.shoulderArt["orc_female_horde"]="shoulders_orc_female_horde"
F.shoulderArt["orc_male_horde"]="shoulders_orc_male_horde"
F.shoulderArt["skyborne_female_alliance"]="shoulders_skyborne_female_alliance"
F.shoulderArt["skyborne_female_horde"]="shoulders_skyborne_female_horde"
F.shoulderArt["skyborne_male_alliance"]="shoulders_skyborne_male_alliance"
F.shoulderArt["tauren_female_horde"]="shoulders_tauren_female_horde"
F.shoulderArt["tauren_male_horde"]="shoulders_tauren_male_horde"
F.shoulderArt["troll_female_horde"]="shoulders_troll_female_horde"
F.shoulderArt["troll_male_horde"]="shoulders_troll_male_horde"
F.shoulderArt["undead_female_horde"]="shoulders_undead_female_horde"
F.shoulderArt["undead_male_horde"]="shoulders_undead_male_horde"
