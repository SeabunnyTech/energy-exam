extends Node

# ===== 政策文字 =====

var wind_policy = """臺灣具備優良離岸風場資源，經濟部參考國際離岸風電發展趨勢，以三階段規劃離岸風電政策推動路徑：「先示範、次潛力、後區塊」，逐步建立我國離岸風電市場開發量能。

全球離岸風電工程進度均受疫情影響，經濟部藉由跨部會合作降低影響，維持設置進度開發，截至2025年6月10日共有408座風力機併網，併網量約3.5GW，全球排名第五，為少數裝置容量突破2GW的國家，經濟部已持續掌握各風場開發期程及辦理進度，並定期召開工作會議追蹤各案場的開發進度。

離岸風電推動階段亦皆辦理多場社會溝通之公民參與機制，如於政策推動階段舉辦相關說明會及座談會、施工前辦理地方說明會等。經濟部持續不定期辦理社會溝通會議，建立與所有利害關係人對話及溝通機制，即時掌握面臨議題與困難，並共同研商解決方案，持續努力推動離岸風電政策。"""

var solar_policy = """太陽光電發展策略依相關法規排除環境敏感地區以複合利用為主，確保光電與生態環境共存，目前已掌握所有案源，需持續跨部會(農業部、內政部)溝通，以達2026年20GW目標。

經濟部推動太陽光電以屋頂型優先，過去已三度調整屋頂型目標到8GW，並於113年3月達成8GW目標，將持續透過法規強制與獎勵措施持續推動，地面型則以複合式利用、不利農業經營及閒置土地，主要以複合式推動，透過一地兩用方式維持原有土地功能加值運用，並透過跨部會溝通合作研議具體且有效落實之機制推動，篩選適宜設置土地，穩健達成淨零排放目標。

漁電共生於區位規劃階段即導入環社檢核機制，透過此機制進行議題辨認，將具生態敏感性區域排除或列入關注減緩區，以利政策推動能兼顧生態保育與在地發展，實現與環境、社會的共存共榮。

經濟部與農業部合作漁電共生新機制，強調前期溝通共識及漁民自主參與；後期強調分流管理，經發單位監督光電營運，農業單位把關養殖行為，倘養殖不佳時，養殖團體可協助輔導養殖，有效促進光電設施與漁業生產之整合，實現「漁業結合綠能」的複合式永續利用目標。"""

var geothermal_policy = """持續發展多元綠能政策，積極投入地熱潛能探勘、提供民間業者地熱能探勘獎勵，以加速淺層地熱開發；針對深層地熱由國營事業(中油、台電等)帶頭，啟動深層地熱鑽探計畫，透過國際合作等方式進行技術驗證、提升鑽井量能，並複製成功經驗擴大設置量，加速深層地熱開發。

透過地熱推動小組研擬地熱能發電推動策略、地熱發電單一服務窗口協助進行跨部會協調溝通等「公對公」推動機制，在解決土地取得、原民諮商等議題下，積極推動地熱能發電，以期加速於2027年達1 GW、2030年達到1.2GW設置目標。

持續召開能源部門社會溝通會議，廣邀各界了解推動成果，確保重點議題有效推進。依地熱推動政策方向與民間環團合作，辦理地熱推動潛能區環社檢核。透過環社檢核機制盤點利害關係人，進行各面向議題辨認，並進行實地訪談與意見歸納，期前研擬因應對策；將持續滾動檢討在地溝通策略，以保障在地居民權益，加速後續案場開發。"""

var hydro_policy = """為落實二次能源轉型與淨零目標，推動多元綠能，小水力可結合既有水利建造物、農田圳路及管渠設施，具低環境衝擊與穩定發電優勢，逐年提升整體裝置容量。

推動策略包含：辦理前期潛力調查與案場獎勵、持續推動設置指引與環境友善工法研析、滾動檢討行政程序並運行單一窗口，並擴大流域與圳路盤點及追蹤機制。

預期效應為提升小水力設置量，目標至119年達約195MW、121年約234MW、124年約237MW，帶動電力排放係數降低、減少碳排放，促進政府、業者與社區共同參與綠能建置。"""

var energy_storage_policy = """持續推動科技儲能政策，鼓勵工業區、園區及廠房於表後設置儲能系統，並同步獎勵產業導入定置型燃料電池發電系統，優先鎖定AI產業、資料中心及半導體等用電大戶，提高產業自發自用比例，擴大分散式電力來源，強化供電穩定與電網韌性。

推動策略包含「新設園區先期整備」與「既有園區加速導入」雙軌並行：未來於新設工業區及科學園區，將儲能建置規範與空間規劃納入園區設計流程；既有園區則透過協助機關鼓勵設置，並推動工廠表後儲能適用時間電價方案、訂定表後儲能消防安全規範，及規劃廠外聯合設置示範區，降低設置門檻。

為提升再生能源併網下的電力調度彈性，協助電力系統尖離峰移轉與穩定供電，並促進用戶用電管理、降低電費支出與提升備援能力；雖科技儲能屬電力系統輔助措施、無直接減碳效益，但可作為淨零轉型關鍵配套，支撐我國能源系統韌性與產業用電安全。"""
var scores_in_topics = reset_scores.duplicate(true)

const reset_scores = {
	'coast' : {
		'wind':{'answered':0, 'correct':0},
		'solar_ground':{'answered':0, 'correct':0},
		'solar_roof':{'answered':0, 'correct':0},
		'energy_storage':{'answered':0, 'correct':0},
	},
	'east' : {
		'geothermal':{'answered':0, 'correct':0},
		'hydro':{'answered':0, 'correct':0},
		'solar_roof':{'answered':0, 'correct':0},
		'energy_storage':{'answered':0, 'correct':0},
	},
	'west' : {
		'solar_ground':{'answered':0, 'correct':0},
		'hydro':{'answered':0, 'correct':0},
		'energy_storage':{'answered':0, 'correct':0},
	},
}

func reset_all_scores():
	scores_in_topics = reset_scores.duplicate(true)


func get_topic_score(map_name:String, topic:String):
	if not scores_in_topics.has(map_name) or not scores_in_topics[map_name].has(topic):
		push_warning("[GameState] get_topic_score: 找不到 map='%s', topic='%s'" % [map_name, topic])
		return {'answered': 0, 'correct': 0}
	return scores_in_topics[map_name][topic]


func push_score(map_name:String, topic:String, is_correct:bool):
	if not scores_in_topics.has(map_name) or not scores_in_topics[map_name].has(topic):
		push_warning("[GameState] push_score: 找不到 map='%s', topic='%s'，請在 reset_scores 中添加" % [map_name, topic])
		return
	var records = scores_in_topics[map_name][topic]
	records['answered'] += 1
	if is_correct:
		records['correct'] += 1

func load_policy(map_name:String, topic:String):
	var policies = {
		'coast' : {
			'wind': wind_policy,
			'solar_ground': solar_policy,
			'solar_roof': solar_policy,
			'energy_storage': energy_storage_policy,
		},
		'west': {
			'solar_ground': solar_policy,
			'hydro': hydro_policy,
			'energy_storage': energy_storage_policy,
		},
		'east' : {
			'geothermal': geothermal_policy,
			'hydro': hydro_policy,
			'solar_roof': solar_policy,
			'energy_storage': energy_storage_policy,
		}
	}
	# 容錯處理
	if not policies.has(map_name):
		push_warning("[GameState] 找不到地圖: %s" % map_name)
		return ""
	if not policies[map_name].has(topic):
		push_warning("[GameState] 找不到主題: map=%s, topic=%s" % [map_name, topic])
		return ""
	return policies[map_name][topic]



func load_topic_title_and_guide(map_name:String, topic:String):
	var data = {
		'coast' : {
			'wind':{
				'title':'離岸風電知多少!',
				'guide':'臺灣位於季風帶，海域風力強勁，適合發展離岸風電，\n利用海上風力發電，可成為低碳主力電源，\n但海上施工與維運成本仍是發展離岸風電的主要挑戰'
			},
			'solar_ground':{
				'title':'地面太陽能發電!',
				'guide':'（地面太陽能引導文字待補充）'
			},
			'solar_roof':{
				'title':'屋頂太陽能發電!',
				'guide':'（屋頂太陽能引導文字待補充）'
			},
			'energy_storage':{
				'title':'儲能系統大解密!',
				'guide':'（儲能引導文字待補充）'
			},
		},
		'west':{
			'solar_ground':{
				'title':'太陽底下都可以成為發電廠!',
				'guide':'你知道當台灣遭遇颱風或地震，\n導致台電的供電線路暫時中斷時\n最能在偏遠的山區或鄉鎮內就近供電的設施是什麼嗎?'
			},
			'hydro':{
				'title':'水力發電!',
				'guide':'（水力發電引導文字待補充）'
			},
			'energy_storage':{
				'title':'儲能系統大解密!',
				'guide':'（儲能引導文字待補充）'
			},
		},
		'east':{
			'geothermal':{
				'title':'來自地心的強大能量!',
				'guide':'你知道我們家裡平常只是用來煮一兩杯米的電鍋，\n已經是家裡耗能的最高的電器之一嗎?\n那麼能夠把整個地殼煮成岩漿的火山能量，\n如果能被用來發電，該是多強大的一股能源呢？'
			},
			'hydro':{
				'title':'水力發電!',
				'guide':'（水力發電引導文字待補充）'
			},
			'solar_roof':{
				'title':'屋頂太陽能發電!',
				'guide':'（屋頂太陽能引導文字待補充）'
			},
			'energy_storage':{
				'title':'儲能系統大解密!',
				'guide':'（儲能引導文字待補充）'
			},
		}
	}
	# 容錯處理
	var fallback = {'title': '[缺少標題] map=%s, topic=%s' % [map_name, topic], 'guide': '[缺少引導文字]'}
	if not data.has(map_name):
		push_warning("[GameState] load_topic_title_and_guide: 找不到地圖 '%s'" % map_name)
		return fallback
	if not data[map_name].has(topic):
		push_warning("[GameState] load_topic_title_and_guide: 找不到主題 map='%s', topic='%s'" % [map_name, topic])
		return fallback
	return data[map_name][topic]
