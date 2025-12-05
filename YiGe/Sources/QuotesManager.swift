//
//  QuotesManager.swift
//  时光格 V3.1 - 今日一言管理（多语言支持）
//

import Foundation

struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let source: String
    let category: QuoteCategory
    let originalText: String?  // V3.1: 原文（英/日/拉丁等）
    let originalLanguage: String?  // V3.1: 原文语言标识
    
    init(text: String, source: String, category: QuoteCategory, originalText: String? = nil, originalLanguage: String? = nil) {
        self.text = text
        self.source = source
        self.category = category
        self.originalText = originalText
        self.originalLanguage = originalLanguage
    }
}

// V3.1: 空状态专用引言（多语言哲思）
struct ContextualQuote: Identifiable {
    let id = UUID()
    let textZh: String
    let textOriginal: String?
    let author: String
    let language: String?  // "en", "la", "ja" 等
}

class QuotesManager: ObservableObject {
    @Published var todayQuote: Quote
    
    // V7.4 修复：洗牌队列，防止重复
    private var shuffledQueue: [Quote] = []
    
    // 动态获取所有名言
    private var allQuotes: [Quote] {
        return Self.philosophyQuotes + Self.poetryQuotes + Self.motivationQuotes + Self.timeQuotes + Self.lifeQuotes
    }
    
    init() {
        // 默认名言
        self.todayQuote = Quote(text: "生活不是等待暴风雨过去，而是学会在雨中跳舞。", source: "维维安·格林", category: .philosophy)
        // 初始化时随机更新一次
        self.updateTodayQuote()
    }
    
    // V3.2: 获取随机名言（用于重记提示等）
    func getRandomQuote() -> Quote {
        if shuffledQueue.isEmpty {
            // 如果队列空了，重新洗牌
            shuffledQueue = allQuotes.shuffled()
        }
        return shuffledQueue.popLast() ?? todayQuote
    }
    
    func updateTodayQuote(category: QuoteCategory = .mixed) {
        // V3.5.1 修改：每次打开都更换名言，不再按天固定
        // 使用洗牌队列逻辑
        todayQuote = getRandomQuote()
    }
    
    func randomQuote(category: QuoteCategory = .mixed) -> Quote {
        // 这里如果是临时随机，也可以用队列，或者直接随机
        return getRandomQuote()
    }
    
    // V3.1: 获取空状态专用的多语言哲思引言
    // V3.5.1 修改：每次调用都返回不同的引言
    func getContextualQuote(for date: Date) -> ContextualQuote {
        // V3.5.1: 不再使用日期作为固定种子，每次随机选择
        let allContextualQuotes = Self.contextualQuotes
        guard !allContextualQuotes.isEmpty else {
            // 如果为空，返回默认引言
            return ContextualQuote(textZh: "把握今天。", textOriginal: "Carpe diem.", author: "贺拉斯", language: "la")
        }
        return allContextualQuotes.randomElement() ?? allContextualQuotes[0]
    }
    
    // V3.1: 多语言哲思引言库
    static let contextualQuotes: [ContextualQuote] = [
        // 拉丁语
        ContextualQuote(textZh: "我思故我在。", textOriginal: "Cogito, ergo sum.", author: "笛卡尔", language: "la"),
        ContextualQuote(textZh: "把握今天。", textOriginal: "Carpe diem.", author: "贺拉斯", language: "la"),
        ContextualQuote(textZh: "艺术永恒，生命短暂。", textOriginal: "Ars longa, vita brevis.", author: "希波克拉底", language: "la"),
        ContextualQuote(textZh: "勇者创造命运。", textOriginal: "Audentes fortuna iuvat.", author: "维吉尔", language: "la"),
        ContextualQuote(textZh: "在怀疑中寻找真理。", textOriginal: "In dubio, veritas.", author: "古罗马谚语", language: "la"),
        
        // 英语
        ContextualQuote(textZh: "凡是过往，皆为序章。", textOriginal: "What's past is prologue.", author: "莎士比亚", language: "en"),
        ContextualQuote(textZh: "生存还是毁灭，这是一个问题。", textOriginal: "To be, or not to be, that is the question.", author: "莎士比亚", language: "en"),
        ContextualQuote(textZh: "我看见，我征服。", textOriginal: "I came, I saw, I conquered.", author: "凯撒", language: "en"),
        ContextualQuote(textZh: "时间是最好的老师。", textOriginal: "Time is the best teacher.", author: "西方谚语", language: "en"),
        ContextualQuote(textZh: "每一天都是新的开始。", textOriginal: "Every day is a new beginning.", author: "西方谚语", language: "en"),
        
        // 日语
        ContextualQuote(textZh: "一期一会。", textOriginal: "一期一会 (Ichigo ichie)", author: "日本茶道", language: "ja"),
        ContextualQuote(textZh: "物哀之美。", textOriginal: "物の哀れ (Mono no aware)", author: "日本美学", language: "ja"),
        ContextualQuote(textZh: "七次跌倒，八次站起。", textOriginal: "七転び八起き (Nana korobi ya oki)", author: "日本谚语", language: "ja"),
        ContextualQuote(textZh: "花开花落，皆有时节。", textOriginal: "花は盛りに (Hana wa sakari ni)", author: "《徒然草》", language: "ja"),
        ContextualQuote(textZh: "侘寂之美，残缺中的完美。", textOriginal: "侘寂 (Wabi-sabi)", author: "日本美学", language: "ja"),
        
        // 中文经典
        ContextualQuote(textZh: "逝者如斯夫，不舍昼夜。", textOriginal: nil, author: "孔子", language: nil),
        ContextualQuote(textZh: "上善若水，水善利万物而不争。", textOriginal: nil, author: "老子", language: nil),
        ContextualQuote(textZh: "人生天地之间，若白驹过隙，忽然而已。", textOriginal: nil, author: "庄子", language: nil),
        ContextualQuote(textZh: "采菊东篱下，悠然见南山。", textOriginal: nil, author: "陶渊明", language: nil),
        ContextualQuote(textZh: "但愿人长久，千里共婵娟。", textOriginal: nil, author: "苏轼", language: nil),
    ]
    
    // MARK: - 哲学名言
    static let philosophyQuotes: [Quote] = [
        Quote(text: "生活不是等待暴风雨过去，而是学会在雨中跳舞。", source: "维维安·格林", category: .philosophy),
        Quote(text: "我思故我在。", source: "笛卡尔", category: .philosophy),
        Quote(text: "未经审视的人生不值得过。", source: "苏格拉底", category: .philosophy),
        Quote(text: "人生最大的荣耀不在于永不跌倒，而在于每次跌倒后都能爬起来。", source: "孔子", category: .philosophy),
        Quote(text: "知之为知之，不知为不知，是知也。", source: "孔子", category: .philosophy),
        Quote(text: "己所不欲，勿施于人。", source: "孔子", category: .philosophy),
        Quote(text: "学而不思则罔，思而不学则殆。", source: "孔子", category: .philosophy),
        Quote(text: "三人行，必有我师焉。", source: "孔子", category: .philosophy),
        Quote(text: "天行健，君子以自强不息。", source: "《周易》", category: .philosophy),
        Quote(text: "上善若水，水善利万物而不争。", source: "老子", category: .philosophy),
        Quote(text: "千里之行，始于足下。", source: "老子", category: .philosophy),
        Quote(text: "道可道，非常道。", source: "老子", category: .philosophy),
        Quote(text: "知人者智，自知者明。", source: "老子", category: .philosophy),
        Quote(text: "大音希声，大象无形。", source: "老子", category: .philosophy),
        Quote(text: "天地不仁，以万物为刍狗。", source: "老子", category: .philosophy),
        Quote(text: "祸兮福之所倚，福兮祸之所伏。", source: "老子", category: .philosophy),
        Quote(text: "人生天地之间，若白驹过隙，忽然而已。", source: "庄子", category: .philosophy),
        Quote(text: "吾生也有涯，而知也无涯。", source: "庄子", category: .philosophy),
        Quote(text: "井蛙不可以语于海者，拘于虚也。", source: "庄子", category: .philosophy),
        Quote(text: "子非鱼，安知鱼之乐？", source: "庄子", category: .philosophy),
        Quote(text: "相濡以沫，不如相忘于江湖。", source: "庄子", category: .philosophy),
        Quote(text: "人无远虑，必有近忧。", source: "孔子", category: .philosophy),
        Quote(text: "岁寒，然后知松柏之后凋也。", source: "孔子", category: .philosophy),
        Quote(text: "仁者见仁，智者见智。", source: "《周易》", category: .philosophy),
        Quote(text: "穷则独善其身，达则兼济天下。", source: "孟子", category: .philosophy),
        Quote(text: "生于忧患，死于安乐。", source: "孟子", category: .philosophy),
        Quote(text: "得道多助，失道寡助。", source: "孟子", category: .philosophy),
        Quote(text: "民为贵，社稷次之，君为轻。", source: "孟子", category: .philosophy),
        Quote(text: "人之初，性本善。", source: "《三字经》", category: .philosophy),
        Quote(text: "不以规矩，不能成方圆。", source: "孟子", category: .philosophy),
        Quote(text: "人皆可以为尧舜。", source: "孟子", category: .philosophy),
        Quote(text: "尽信书，则不如无书。", source: "孟子", category: .philosophy),
        Quote(text: "凡事预则立，不预则废。", source: "《礼记》", category: .philosophy),
        Quote(text: "博学之，审问之，慎思之，明辨之，笃行之。", source: "《中庸》", category: .philosophy),
        Quote(text: "路漫漫其修远兮，吾将上下而求索。", source: "屈原", category: .philosophy),
        Quote(text: "玉不琢，不成器；人不学，不知道。", source: "《礼记》", category: .philosophy),
        Quote(text: "见贤思齐焉，见不贤而内自省也。", source: "孔子", category: .philosophy),
        Quote(text: "工欲善其事，必先利其器。", source: "孔子", category: .philosophy),
        Quote(text: "人非圣贤，孰能无过。", source: "《左传》", category: .philosophy),
        Quote(text: "君子坦荡荡，小人长戚戚。", source: "孔子", category: .philosophy),
        Quote(text: "知足者常乐。", source: "老子", category: .philosophy),
        Quote(text: "静以修身，俭以养德。", source: "诸葛亮", category: .philosophy),
        Quote(text: "非淡泊无以明志，非宁静无以致远。", source: "诸葛亮", category: .philosophy),
        Quote(text: "勿以恶小而为之，勿以善小而不为。", source: "刘备", category: .philosophy),
        Quote(text: "读万卷书，行万里路。", source: "董其昌", category: .philosophy),
        Quote(text: "知行合一。", source: "王阳明", category: .philosophy),
        Quote(text: "人生自古谁无死，留取丹心照汗青。", source: "文天祥", category: .philosophy),
        Quote(text: "天下兴亡，匹夫有责。", source: "顾炎武", category: .philosophy),
        Quote(text: "业精于勤，荒于嬉。", source: "韩愈", category: .philosophy),
        Quote(text: "世上无难事，只怕有心人。", source: "俗语", category: .philosophy),
        Quote(text: "纸上得来终觉浅，绝知此事要躬行。", source: "陆游", category: .philosophy),
        Quote(text: "横眉冷对千夫指，俯首甘为孺子牛。", source: "鲁迅", category: .philosophy),
        Quote(text: "真的猛士，敢于直面惨淡的人生。", source: "鲁迅", category: .philosophy),
        Quote(text: "人最宝贵的是生命，生命每个人只有一次。", source: "奥斯特洛夫斯基", category: .philosophy),
        Quote(text: "生活总是让我们遍体鳞伤，但到后来，那些受伤的地方一定会变成我们最强壮的地方。", source: "海明威", category: .philosophy),
        Quote(text: "世界上只有一种英雄主义，就是看清生活的真相之后依然热爱生活。", source: "罗曼·罗兰", category: .philosophy),
        Quote(text: "我来到这个世界，不是为了活着，而是为了生活。", source: "奥斯卡·王尔德", category: .philosophy),
        Quote(text: "幸福的家庭都是相似的，不幸的家庭各有各的不幸。", source: "托尔斯泰", category: .philosophy),
        Quote(text: "凡是过往，皆为序章。", source: "莎士比亚", category: .philosophy),
        Quote(text: "生存还是毁灭，这是一个问题。", source: "莎士比亚", category: .philosophy),
        Quote(text: "知识就是力量。", source: "培根", category: .philosophy),
        Quote(text: "我唯一知道的就是我一无所知。", source: "苏格拉底", category: .philosophy),
        Quote(text: "人是万物的尺度。", source: "普罗泰戈拉", category: .philosophy),
        Quote(text: "给我一个支点，我就能撬动地球。", source: "阿基米德", category: .philosophy),
        Quote(text: "人不能两次踏进同一条河流。", source: "赫拉克利特", category: .philosophy),
        Quote(text: "吾爱吾师，吾更爱真理。", source: "亚里士多德", category: .philosophy),
        Quote(text: "幸福是人生的最高善。", source: "亚里士多德", category: .philosophy),
        Quote(text: "存在即合理。", source: "黑格尔", category: .philosophy),
        Quote(text: "人是生而自由的，却无往不在枷锁之中。", source: "卢梭", category: .philosophy),
        Quote(text: "他人即地狱。", source: "萨特", category: .philosophy),
        Quote(text: "存在先于本质。", source: "萨特", category: .philosophy),
    ]
    
    // MARK: - 古诗词
    static let poetryQuotes: [Quote] = [
        Quote(text: "床前明月光，疑是地上霜。举头望明月，低头思故乡。", source: "李白《静夜思》", category: .poetry),
        Quote(text: "白日依山尽，黄河入海流。欲穷千里目，更上一层楼。", source: "王之涣《登鹳雀楼》", category: .poetry),
        Quote(text: "春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。", source: "孟浩然《春晓》", category: .poetry),
        Quote(text: "红豆生南国，春来发几枝。愿君多采撷，此物最相思。", source: "王维《相思》", category: .poetry),
        Quote(text: "独在异乡为异客，每逢佳节倍思亲。", source: "王维《九月九日忆山东兄弟》", category: .poetry),
        Quote(text: "大漠孤烟直，长河落日圆。", source: "王维《使至塞上》", category: .poetry),
        Quote(text: "空山新雨后，天气晚来秋。明月松间照，清泉石上流。", source: "王维《山居秋暝》", category: .poetry),
        Quote(text: "行到水穷处，坐看云起时。", source: "王维《终南别业》", category: .poetry),
        Quote(text: "海内存知己，天涯若比邻。", source: "王勃《送杜少府之任蜀州》", category: .poetry),
        Quote(text: "落霞与孤鹜齐飞，秋水共长天一色。", source: "王勃《滕王阁序》", category: .poetry),
        Quote(text: "前不见古人，后不见来者。念天地之悠悠，独怆然而涕下。", source: "陈子昂《登幽州台歌》", category: .poetry),
        Quote(text: "海上生明月，天涯共此时。", source: "张九龄《望月怀远》", category: .poetry),
        Quote(text: "慈母手中线，游子身上衣。临行密密缝，意恐迟迟归。", source: "孟郊《游子吟》", category: .poetry),
        Quote(text: "离离原上草，一岁一枯荣。野火烧不尽，春风吹又生。", source: "白居易《赋得古原草送别》", category: .poetry),
        Quote(text: "日出江花红胜火，春来江水绿如蓝。", source: "白居易《忆江南》", category: .poetry),
        Quote(text: "在天愿作比翼鸟，在地愿为连理枝。", source: "白居易《长恨歌》", category: .poetry),
        Quote(text: "同是天涯沦落人，相逢何必曾相识。", source: "白居易《琵琶行》", category: .poetry),
        Quote(text: "千呼万唤始出来，犹抱琵琶半遮面。", source: "白居易《琵琶行》", category: .poetry),
        Quote(text: "乱花渐欲迷人眼，浅草才能没马蹄。", source: "白居易《钱塘湖春行》", category: .poetry),
        Quote(text: "朱门酒肉臭，路有冻死骨。", source: "杜甫《自京赴奉先县咏怀五百字》", category: .poetry),
        Quote(text: "会当凌绝顶，一览众山小。", source: "杜甫《望岳》", category: .poetry),
        Quote(text: "国破山河在，城春草木深。感时花溅泪，恨别鸟惊心。", source: "杜甫《春望》", category: .poetry),
        Quote(text: "安得广厦千万间，大庇天下寒士俱欢颜。", source: "杜甫《茅屋为秋风所破歌》", category: .poetry),
        Quote(text: "读书破万卷，下笔如有神。", source: "杜甫《奉赠韦左丞丈二十二韵》", category: .poetry),
        Quote(text: "露从今夜白，月是故乡明。", source: "杜甫《月夜忆舍弟》", category: .poetry),
        Quote(text: "两个黄鹂鸣翠柳，一行白鹭上青天。", source: "杜甫《绝句》", category: .poetry),
        Quote(text: "飞流直下三千尺，疑是银河落九天。", source: "李白《望庐山瀑布》", category: .poetry),
        Quote(text: "两岸猿声啼不住，轻舟已过万重山。", source: "李白《早发白帝城》", category: .poetry),
        Quote(text: "故人西辞黄鹤楼，烟花三月下扬州。", source: "李白《黄鹤楼送孟浩然之广陵》", category: .poetry),
        Quote(text: "桃花潭水深千尺，不及汪伦送我情。", source: "李白《赠汪伦》", category: .poetry),
        Quote(text: "孤帆远影碧空尽，唯见长江天际流。", source: "李白《黄鹤楼送孟浩然之广陵》", category: .poetry),
        Quote(text: "举杯邀明月，对影成三人。", source: "李白《月下独酌》", category: .poetry),
        Quote(text: "抽刀断水水更流，举杯消愁愁更愁。", source: "李白《宣州谢朓楼饯别校书叔云》", category: .poetry),
        Quote(text: "蜀道之难，难于上青天。", source: "李白《蜀道难》", category: .poetry),
        Quote(text: "君不见黄河之水天上来，奔流到海不复回。", source: "李白《将进酒》", category: .poetry),
        Quote(text: "但愿人长久，千里共婵娟。", source: "苏轼《水调歌头》", category: .poetry),
        Quote(text: "不识庐山真面目，只缘身在此山中。", source: "苏轼《题西林壁》", category: .poetry),
        Quote(text: "竹外桃花三两枝，春江水暖鸭先知。", source: "苏轼《惠崇春江晚景》", category: .poetry),
        Quote(text: "大江东去，浪淘尽，千古风流人物。", source: "苏轼《念奴娇·赤壁怀古》", category: .poetry),
        Quote(text: "人有悲欢离合，月有阴晴圆缺，此事古难全。", source: "苏轼《水调歌头》", category: .poetry),
        Quote(text: "回首向来萧瑟处，归去，也无风雨也无晴。", source: "苏轼《定风波》", category: .poetry),
        Quote(text: "十年生死两茫茫，不思量，自难忘。", source: "苏轼《江城子》", category: .poetry),
        Quote(text: "欲把西湖比西子，淡妆浓抹总相宜。", source: "苏轼《饮湖上初晴后雨》", category: .poetry),
        Quote(text: "问君能有几多愁，恰似一江春水向东流。", source: "李煜《虞美人》", category: .poetry),
        Quote(text: "春花秋月何时了，往事知多少。", source: "李煜《虞美人》", category: .poetry),
        Quote(text: "剪不断，理还乱，是离愁，别是一般滋味在心头。", source: "李煜《相见欢》", category: .poetry),
        Quote(text: "无可奈何花落去，似曾相识燕归来。", source: "晏殊《浣溪沙》", category: .poetry),
        Quote(text: "昨夜西风凋碧树，独上高楼，望尽天涯路。", source: "晏殊《蝶恋花》", category: .poetry),
        Quote(text: "衣带渐宽终不悔，为伊消得人憔悴。", source: "柳永《蝶恋花》", category: .poetry),
        Quote(text: "执手相看泪眼，竟无语凝噎。", source: "柳永《雨霖铃》", category: .poetry),
        Quote(text: "寻寻觅觅，冷冷清清，凄凄惨惨戚戚。", source: "李清照《声声慢》", category: .poetry),
        Quote(text: "知否，知否？应是绿肥红瘦。", source: "李清照《如梦令》", category: .poetry),
        Quote(text: "生当作人杰，死亦为鬼雄。", source: "李清照《夏日绝句》", category: .poetry),
        Quote(text: "花自飘零水自流，一种相思，两处闲愁。", source: "李清照《一剪梅》", category: .poetry),
        Quote(text: "此情无计可消除，才下眉头，却上心头。", source: "李清照《一剪梅》", category: .poetry),
        Quote(text: "怒发冲冠，凭栏处、潇潇雨歇。", source: "岳飞《满江红》", category: .poetry),
        Quote(text: "三十功名尘与土，八千里路云和月。", source: "岳飞《满江红》", category: .poetry),
        Quote(text: "醉里挑灯看剑，梦回吹角连营。", source: "辛弃疾《破阵子》", category: .poetry),
        Quote(text: "众里寻他千百度，蓦然回首，那人却在灯火阑珊处。", source: "辛弃疾《青玉案》", category: .poetry),
        Quote(text: "稻花香里说丰年，听取蛙声一片。", source: "辛弃疾《西江月》", category: .poetry),
        Quote(text: "青山遮不住，毕竟东流去。", source: "辛弃疾《菩萨蛮》", category: .poetry),
        Quote(text: "我见青山多妩媚，料青山见我应如是。", source: "辛弃疾《贺新郎》", category: .poetry),
        Quote(text: "采菊东篱下，悠然见南山。", source: "陶渊明《饮酒》", category: .poetry),
        Quote(text: "问君何能尔？心远地自偏。", source: "陶渊明《饮酒》", category: .poetry),
        Quote(text: "羁鸟恋旧林，池鱼思故渊。", source: "陶渊明《归园田居》", category: .poetry),
        Quote(text: "久在樊笼里，复得返自然。", source: "陶渊明《归园田居》", category: .poetry),
        Quote(text: "曾经沧海难为水，除却巫山不是云。", source: "元稹《离思》", category: .poetry),
        Quote(text: "春蚕到死丝方尽，蜡炬成灰泪始干。", source: "李商隐《无题》", category: .poetry),
        Quote(text: "身无彩凤双飞翼，心有灵犀一点通。", source: "李商隐《无题》", category: .poetry),
        Quote(text: "何当共剪西窗烛，却话巴山夜雨时。", source: "李商隐《夜雨寄北》", category: .poetry),
        Quote(text: "夕阳无限好，只是近黄昏。", source: "李商隐《乐游原》", category: .poetry),
    ]
    
    // MARK: - 时光主题名言（V3.2 新增，用于重记提示）
    static let timeQuotes: [Quote] = [
        Quote(text: "时间是最好的老师，可惜它会杀死所有学生。", source: "柏林谚语", category: .philosophy),
        Quote(text: "时光飞逝，唯有记忆永恒。", source: "佚名", category: .philosophy),
        Quote(text: "昨日之日不可留，今日之日多烦忧。", source: "李白", category: .poetry),
        Quote(text: "盛年不重来，一日难再晨。", source: "陶渊明", category: .poetry),
        Quote(text: "时间就是金钱。", source: "本杰明·富兰克林", category: .motivation),
        Quote(text: "浪费别人的时间等于谋财害命。", source: "鲁迅", category: .philosophy),
        Quote(text: "时间是一切财富中最宝贵的财富。", source: "德奥弗拉斯多", category: .philosophy),
        Quote(text: "时间就是生命，无端的空耗别人的时间，其实是无异于谋财害命的。", source: "鲁迅", category: .philosophy),
        Quote(text: "你热爱生命吗？那么别浪费时间，因为时间是组成生命的材料。", source: "富兰克林", category: .motivation),
        Quote(text: "时间是世界上一切成就的土壤。", source: "麦金西", category: .motivation),
        Quote(text: "时间是由分秒积成的，善于利用零星时间的人，才会做出更大的成绩来。", source: "华罗庚", category: .motivation),
        Quote(text: "在所有的批评家中，最伟大、最正确、最天才的是时间。", source: "别林斯基", category: .philosophy),
        Quote(text: "时间给勤勉的人留下智慧的力量，给懒惰的人留下空虚和悔恨。", source: "佚名", category: .motivation),
        Quote(text: "黑发不知勤学早，白首方悔读书迟。", source: "颜真卿", category: .poetry),
        Quote(text: "少壮不努力，老大徒伤悲。", source: "《长歌行》", category: .poetry),
        Quote(text: "一寸光阴一寸金，寸金难买寸光阴。", source: "俗语", category: .philosophy),
        Quote(text: "莫等闲，白了少年头，空悲切。", source: "岳飞", category: .poetry),
        Quote(text: "时间像海绵里的水，只要愿挤，总还是有的。", source: "鲁迅", category: .motivation),
        Quote(text: "明日复明日，明日何其多。我生待明日，万事成蹉跎。", source: "钱鹤滩", category: .poetry),
        Quote(text: "子在川上曰：逝者如斯夫，不舍昼夜。", source: "《论语》", category: .philosophy),
    ]
    
    // MARK: - 生活感悟（V3.2 新增）
    static let lifeQuotes: [Quote] = [
        Quote(text: "生活不止眼前的苟且，还有诗和远方。", source: "高晓松", category: .motivation),
        Quote(text: "愿你出走半生，归来仍是少年。", source: "苏轼", category: .poetry),
        Quote(text: "人生若只如初见，何事秋风悲画扇。", source: "纳兰性德", category: .poetry),
        Quote(text: "山有木兮木有枝，心悦君兮君不知。", source: "《越人歌》", category: .poetry),
        Quote(text: "人生得意须尽欢，莫使金樽空对月。", source: "李白", category: .poetry),
        Quote(text: "天生我材必有用，千金散尽还复来。", source: "李白", category: .poetry),
        Quote(text: "长风破浪会有时，直挂云帆济沧海。", source: "李白", category: .poetry),
        Quote(text: "山重水复疑无路，柳暗花明又一村。", source: "陆游", category: .poetry),
        Quote(text: "沉舟侧畔千帆过，病树前头万木春。", source: "刘禹锡", category: .poetry),
        Quote(text: "落红不是无情物，化作春泥更护花。", source: "龚自珍", category: .poetry),
        Quote(text: "海内存知己，天涯若比邻。", source: "王勃", category: .poetry),
        Quote(text: "莫愁前路无知己，天下谁人不识君。", source: "高适", category: .poetry),
        Quote(text: "桃李不言，下自成蹊。", source: "司马迁", category: .philosophy),
        Quote(text: "宁可枝头抱香死，何曾吹落北风中。", source: "郑思肖", category: .poetry),
        Quote(text: "粉身碎骨浑不怕，要留清白在人间。", source: "于谦", category: .poetry),
        Quote(text: "千磨万击还坚劲，任尔东西南北风。", source: "郑燮", category: .poetry),
        Quote(text: "不要因为走得太远，而忘记为什么出发。", source: "纪伯伦", category: .philosophy),
        Quote(text: "生活是一面镜子，你对它笑，它就对你笑。", source: "萨克雷", category: .philosophy),
        Quote(text: "世界上最宽阔的是海洋，比海洋更宽阔的是天空，比天空更宽阔的是人的胸怀。", source: "雨果", category: .philosophy),
        Quote(text: "生活的理想，就是为了理想的生活。", source: "张闻天", category: .motivation),
    ]
    
    // MARK: - 励志语录
    static let motivationQuotes: [Quote] = [
        Quote(text: "成功不是终点，失败也不是终结，唯有继续前进的勇气才是最重要的。", source: "丘吉尔", category: .motivation),
        Quote(text: "每一个不曾起舞的日子，都是对生命的辜负。", source: "尼采", category: .motivation),
        Quote(text: "你的时间有限，不要浪费在过别人的生活上。", source: "乔布斯", category: .motivation),
        Quote(text: "保持饥饿，保持愚蠢。", source: "乔布斯", category: .motivation),
        Quote(text: "活着就是为了改变世界，难道还有其他原因吗？", source: "乔布斯", category: .motivation),
        Quote(text: "只有那些疯狂到认为自己可以改变世界的人，才能真正改变世界。", source: "乔布斯", category: .motivation),
        Quote(text: "我不是失败了一万次，我只是发现了一万种不可行的方法。", source: "爱迪生", category: .motivation),
        Quote(text: "天才是百分之一的灵感加上百分之九十九的汗水。", source: "爱迪生", category: .motivation),
        Quote(text: "如果你想走得快，就一个人走；如果你想走得远，就一起走。", source: "非洲谚语", category: .motivation),
        Quote(text: "成功的秘诀在于始终如一地坚持目标。", source: "本杰明·迪斯雷利", category: .motivation),
        Quote(text: "一个人可以被毁灭，但不能被打败。", source: "海明威", category: .motivation),
        Quote(text: "伟大的作品不是靠力量，而是靠坚持完成的。", source: "约翰逊", category: .motivation),
        Quote(text: "只有不断找寻机会的人才会及时把握机会。", source: "萧伯纳", category: .motivation),
        Quote(text: "命运不是机遇，而是选择。", source: "布莱恩·特蕾西", category: .motivation),
        Quote(text: "成功是一种态度！", source: "拿破仑·希尔", category: .motivation),
        Quote(text: "没有人可以回到过去重新开始，但每个人都可以从今天开始创造新的结局。", source: "玛丽亚·罗宾逊", category: .motivation),
        Quote(text: "行动是治愈恐惧的良药，而犹豫和拖延将不断滋养恐惧。", source: "戴尔·卡耐基", category: .motivation),
        Quote(text: "当你停止学习的时候，你就停止成长了。", source: "阿尔伯特·爱因斯坦", category: .motivation),
        Quote(text: "想象力比知识更重要。", source: "爱因斯坦", category: .motivation),
        Quote(text: "人生最大的错误是不断担心会犯错。", source: "埃尔伯特·哈伯德", category: .motivation),
        Quote(text: "成功的人是跟别人学习经验，失败的人只跟自己学习经验。", source: "佚名", category: .motivation),
        Quote(text: "当你觉得为时已晚的时候，恰恰是最早的时候。", source: "哈佛校训", category: .motivation),
        Quote(text: "此刻打盹，你将做梦；此刻学习，你将圆梦。", source: "哈佛校训", category: .motivation),
        Quote(text: "幸福或许不排名次，但成功必排名次。", source: "哈佛校训", category: .motivation),
        Quote(text: "学习不是人生的全部，但连学习都征服不了，你还能做什么？", source: "哈佛校训", category: .motivation),
        Quote(text: "今天不走，明天即使跑也不一定跟得上。", source: "哈佛校训", category: .motivation),
        Quote(text: "投资未来的人，是忠于现实的人。", source: "哈佛校训", category: .motivation),
        Quote(text: "教育程度代表收入。", source: "哈佛校训", category: .motivation),
        Quote(text: "一天过完，不会再来。", source: "哈佛校训", category: .motivation),
        Quote(text: "即使现在，对手也在不停地翻动书页。", source: "哈佛校训", category: .motivation),
        Quote(text: "没有艰辛，便无所获。", source: "哈佛校训", category: .motivation),
        Quote(text: "不要抱怨不公平，一切只因努力还不够。", source: "佚名", category: .motivation),
        Quote(text: "你要悄悄拔尖，然后惊艳所有人。", source: "佚名", category: .motivation),
        Quote(text: "世界会向那些有目标和远见的人让路。", source: "冯两努", category: .motivation),
        Quote(text: "如果你想攀登高峰，切莫把彩虹当作梯子。", source: "徐志摩", category: .motivation),
        Quote(text: "生命太短暂，没时间遗憾，一分钟都不要留给那些让你不快的人或事。", source: "佚名", category: .motivation),
        Quote(text: "不管你去往何方，不管将来迎接你的是什么，请你带着阳光般的心情启程。", source: "佚名", category: .motivation),
        Quote(text: "这世界上没有优秀的理念，只有脚踏实地的结果。", source: "马云", category: .motivation),
        Quote(text: "今天很残酷，明天更残酷，后天很美好，但是大多数人死在明天晚上。", source: "马云", category: .motivation),
        Quote(text: "梦想还是要有的，万一实现了呢？", source: "马云", category: .motivation),
        Quote(text: "不要让任何人告诉你：你的梦想不切实际。", source: "佚名", category: .motivation),
        Quote(text: "努力到无能为力，拼搏到感动自己。", source: "佚名", category: .motivation),
        Quote(text: "你若盛开，蝴蝶自来；你若精彩，天自安排。", source: "佚名", category: .motivation),
        Quote(text: "愿你出走半生，归来仍是少年。", source: "苏轼", category: .motivation),
        Quote(text: "人生没有白走的路，每一步都算数。", source: "佚名", category: .motivation),
        Quote(text: "越努力，越幸运。", source: "佚名", category: .motivation),
        Quote(text: "不负光阴不负己。", source: "佚名", category: .motivation),
        Quote(text: "星光不问赶路人，时光不负有心人。", source: "佚名", category: .motivation),
        Quote(text: "所有的光鲜亮丽，背后都有辛苦付出。所有的现世静好，背后都是咬牙坚持。", source: "佚名", category: .motivation),
        Quote(text: "你现在的努力，是为了以后有更多的选择。", source: "佚名", category: .motivation),
        Quote(text: "把每一天当作生命的最后一天来过。", source: "乔布斯", category: .motivation),
        Quote(text: "记住你即将死去，这是我知道的避免患得患失的最好方法。", source: "乔布斯", category: .motivation),
        Quote(text: "生活就像一盒巧克力，你永远不知道下一块是什么味道。", source: "《阿甘正传》", category: .motivation),
        Quote(text: "人生就像骑自行车，要保持平衡就得不断前进。", source: "爱因斯坦", category: .motivation),
        Quote(text: "做一个温暖的人，用加法去爱人，用减法去怨恨，用乘法去感恩。", source: "佚名", category: .motivation),
        Quote(text: "你要做一个不动声色的大人了。", source: "村上春树", category: .motivation),
        Quote(text: "世界上没有绝望的处境，只有对处境绝望的人。", source: "佚名", category: .motivation),
        Quote(text: "认真的人改变自己，执着的人改变命运。", source: "佚名", category: .motivation),
        Quote(text: "每个人都在奋不顾身，都在加倍努力，你没有理由一边委屈一边抱怨人世寒冷。", source: "佚名", category: .motivation),
        Quote(text: "当你的才华还撑不起你的野心时，你就应该静下心来学习。", source: "佚名", category: .motivation),
        Quote(text: "与其担心未来，不如现在好好努力。", source: "佚名", category: .motivation),
        Quote(text: "抱怨身处黑暗，不如提灯前行。", source: "刘同", category: .motivation),
        Quote(text: "你不必生来勇敢，天赋过人。只要能投入勤奋，诚诚恳恳。", source: "佚名", category: .motivation),
        Quote(text: "请你一定要相信自己，一定要让自己变成你真心喜欢的那个自己。", source: "佚名", category: .motivation),
        Quote(text: "生活明朗，万物可爱，人间值得，未来可期。", source: "佚名", category: .motivation),
    ]
}
