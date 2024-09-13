module aptosswap::vpt {
    const EVptZeroEncountering: u64 = 18301;

    struct ValuePerToken has store, copy, drop {
        sum: u256,
        amount: u256,
    }

    public fun vpt(sum: u256, amount: u256): ValuePerToken {
        assert!((sum == 0 || amount > 0), EVptZeroEncountering);
        ValuePerToken { sum: sum, amount: amount }
    }

    public fun zero(): ValuePerToken {
        vpt(0, 0)
    }

    public fun sum(v: &ValuePerToken): u256 { v.sum }
    public fun amount(v: &ValuePerToken): u256 { v.amount }

    public fun value(v: &ValuePerToken): u256 {
        if (v.sum == 0 && v.amount == 0) {
            0 
        } else { 
            v.sum / v.amount 
        }
    }

    public fun add_sum(v: &mut ValuePerToken, value: u256) {
        assert!(v.amount > 0, EVptZeroEncountering);
        v.sum = v.sum + value;
    }

    public fun dec_sum(v: &mut ValuePerToken, value: u256) {
        assert!(v.amount > 0, EVptZeroEncountering);
        v.sum = v.sum - value;
    }

    public fun add_amount(v: &mut ValuePerToken, amount: u256) {
        let amount_ = v.amount + amount;
        let sum_ = if (v.amount > 0) { v.sum * amount_ / v.amount } else { 0 };
        v.sum = sum_;
        v.amount = amount_;
    }

    public fun dec_amount(v: &mut ValuePerToken, amount: u256) {
        let amount_ = v.amount - amount;
        let sum_ = if (v.amount > 0) { v.sum * amount_ / v.amount } else { 0 };
        v.sum = sum_;
        v.amount = amount_;
    }

    
    public fun diff(v1: &ValuePerToken, v2: &ValuePerToken, mul: u256): u256 {
        // The actual value is (s1 a2 - s2 a1) / (a1 a2)
        let (s1, a1) = if (v1.amount == 0 && v1.sum == 0) { (0, 1) } else { (v1.sum, v1.amount) };
        let (s2, a2) = if (v2.amount == 0 && v2.sum == 0) { (0, 1) } else { (v2.sum, v2.amount) };
        let n1 = s1 * a2;
        let n2 = s2 * a1;
        let d = a1 * a2;
        let res: u256 = if (n1 >= n2) { (n1 - n2) * mul / d } else { 0 };
        res
    }


    #[test] fun t_vpt_add_dec_sum() {
        let v1 = vpt(14588821654402139066594352266188630859832391687538197994061054180251151172816, 67458850130313463845137005121670691792110702535815820592698052484730960387663); add_sum(&mut v1, 12338431543923365363492187088844013337179409325925800477809675919470864061272); assert!(v1.sum == 26927253198325504430086539355032644197011801013463998471870730099722015234088 && v1.amount == 67458850130313463845137005121670691792110702535815820592698052484730960387663, 0);
        let v1 = vpt(4488954389304030764712260948610711676232924836996083502113351842072327279013, 92342302805381352027025877303692444036238333530755804369182838469156258477595); dec_sum(&mut v1, 1404430897589067883843879403192313488749659240731700518797031068985517731701); assert!(v1.sum == 3084523491714962880868381545418398187483265596264382983316320773086809547312 && v1.amount == 92342302805381352027025877303692444036238333530755804369182838469156258477595, 0);
        let v1 = vpt(53522557874848870338575512553548063658722210879060622739522174875624179337989, 9799918290); add_sum(&mut v1, 9758809438949201179001065801407907626010995756281664288078466112664738011738); assert!(v1.sum == 63281367313798071517576578354955971284733206635342287027600640988288917349727 && v1.amount == 9799918290, 0);
        let v1 = vpt(20362060078196420195472680087116734734000112972849081035063156458451798900567, 7306872568); dec_sum(&mut v1, 10606526619960593411321753173738297194347086246683161753109601976558775441533); assert!(v1.sum == 9755533458235826784150926913378437539653026726165919281953554481893023459034 && v1.amount == 7306872568, 0);
        let v1 = vpt(3723442113500326511766962067053743345518350345351792641925370621990800356703, 5334689178); add_sum(&mut v1, 3641809044346297607866529065115760982920777266216867615360372174970840164089); assert!(v1.sum == 7365251157846624119633491132169504328439127611568660257285742796961640520792 && v1.amount == 5334689178, 0);
        let v1 = vpt(25375430495491721366809549551178826934015669262905551367701083252585701082379, 3278466611); dec_sum(&mut v1, 24904550595684140866525462065634269071716173807344828159083351565035790582618); assert!(v1.sum == 470879899807580500284087485544557862299495455560723208617731687549910499761 && v1.amount == 3278466611, 0);
        let v1 = vpt(52308967201977851268899193554127916032640598550544033766650649741028261599415, 93199617527460529424784435648780951546466805434623664852236330348690695694528); add_sum(&mut v1, 28624982583666548127430394985194093099717612992803313584466571254915218007214); assert!(v1.sum == 80933949785644399396329588539322009132358211543347347351117220995943479606629 && v1.amount == 93199617527460529424784435648780951546466805434623664852236330348690695694528, 0);
    }

    #[test] fun t_vpt_add_dec_amount() {
        let v1 = vpt(47663983865972305161790272488230268105, 2708451591439020); let v2 = copy v1; add_amount(&mut v1, 6166705614460974841); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(321236637633076500382151180759428851959, 9304285248516585682); let v2 = copy v1; add_amount(&mut v1, 5); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(18450781434144918455223982363772349209, 9881744333353784475); let v2 = copy v1; dec_amount(&mut v1, 5); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(2820220780651474599811556745221524634, 3883186125784456093); let v2 = copy v1; dec_amount(&mut v1, 1377097101350899779); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(182315684403434434930561207143554379790, 2947229326484140); let v2 = copy v1; add_amount(&mut v1, 68685583349725614); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(252970006438380007133793453650338514470, 3); let v2 = copy v1; add_amount(&mut v1, 3623981892172878726); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(129077194346318610157467414855603541271, 15190818317139522); let v2 = copy v1; dec_amount(&mut v1, 15190818317139522); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(0, 0); let v2 = copy v1; add_amount(&mut v1, 7045); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(327430291194832205663299571057822910365, 10326971918019589639); let v2 = copy v1; add_amount(&mut v1, 6); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(229838313691126076941031727584313187415, 2); let v2 = copy v1; dec_amount(&mut v1, 2); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(295568252944840122965222274153435439445, 9237); let v2 = copy v1; dec_amount(&mut v1, 9237); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(16376963523639401041187070414821711643, 4547); let v2 = copy v1; dec_amount(&mut v1, 4547); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(96261554938235143598805869249122880811, 4); let v2 = copy v1; add_amount(&mut v1, 9132021484481924181); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(13975709669889945671759337934686149931, 8); let v2 = copy v1; add_amount(&mut v1, 15232806151917396270); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(280556527901821986118382236498584020157, 2887596809188682132); let v2 = copy v1; dec_amount(&mut v1, 79118268989318784); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(327083583658108880032656367857663847132, 57454356113882921); let v2 = copy v1; dec_amount(&mut v1, 1); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(207076033551424719040606360054943558731, 1); let v2 = copy v1; dec_amount(&mut v1, 1); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(238854945211111303289399749893183774893, 27425319185686021); let v2 = copy v1; add_amount(&mut v1, 1); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(122344875690015032569095543101028073664, 2986); let v2 = copy v1; add_amount(&mut v1, 13710860814030503631); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(0, 0); let v2 = copy v1; add_amount(&mut v1, 0); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(0, 0); let v2 = copy v1; dec_amount(&mut v1, 0); assert!(value(&v1) <= value(&v2), 0);
        let v1 = vpt(0, 12); dec_amount(&mut v1, 12); assert!(v1.sum == 0 && v1.amount == 0, 0);
        let v1 = vpt(13, 12); dec_amount(&mut v1, 12); assert!(v1.sum == 0 && v1.amount == 0, 0);
    }

    #[test] fun t_vpt_diff_value() {
        let v1 = vpt(3236873322325895, 268); let v2 = vpt(132052911642061851403580966937814523385, 9356); assert!(diff(&v1, &v2, (95462920604836176 as u256)) == 0, 0);
        let v1 = vpt(62316695348335839, 47783643089183227); let v2 = vpt(2067103332941597, 875); assert!(diff(&v1, &v2, (18919975294674666 as u256)) == 0, 0);
        let v1 = vpt(43846085650777443, 252142859853292); let v2 = vpt(2313039551856423, 812935311601535); assert!(diff(&v1, &v2, (88745730100846601 as u256)) == 15179826566507900835, 0);
        let v1 = vpt(81399068369506077142658430468797345927, 7); let v2 = vpt(42083962420835132388528804117222500320, 3); assert!(diff(&v1, &v2, (87609922828042362 as u256)) == 0, 0);
        let v1 = vpt(203285236829130027037946045356944114509, 9); let v2 = vpt(153989170894515482691722426835354321751, 4); assert!(diff(&v1, &v2, (55550899822376071 as u256)) == 0, 0);
        let v1 = vpt(34848710189246893411307172750865302982, 77824384589739987); let v2 = vpt(252119022842919266186879110135564679486, 9775); assert!(diff(&v1, &v2, (54980245956756116 as u256)) == 0, 0);
        let v1 = vpt(5701038081284524, 1309615830497347); let v2 = vpt(8856950188457661, 8); assert!(diff(&v1, &v2, (59273640891772376 as u256)) == 0, 0);
        let v1 = vpt(18087010701522102, 1); let v2 = vpt(1337700883641571, 6504); assert!(diff(&v1, &v2, (63975942837511306 as u256)) == 1157120404581629582493988833859981, 0);
        let v1 = vpt(303355243795684118808984251940290317477, 6912); let v2 = vpt(26201737250762906017051911361424027011, 11393368435837495); assert!(diff(&v1, &v2, (33326370889989824 as u256)) == 1462634456909392886761538457261312027382748952309820, 0);
        let v1 = vpt(97104773947581880, 62042675556464157); let v2 = vpt(160073253876031158500670194602704039935, 1); assert!(diff(&v1, &v2, (64354157704743948 as u256)) == 0, 0);
        let v1 = vpt(57503001820517529, 8); let v2 = zero(); assert!(diff(&v1, &v2, (40393248069896646 as u256)) == 290341627162485374928782657663466, 0);
        let v1 = vpt(0, 0); let v2 = vpt(0, 0); assert!(diff(&v1, &v2, (112 as u256)) == 0, 0);
        let v1 = vpt(0, 0); let v2 = vpt(0, 1); assert!(diff(&v1, &v2, (123 as u256)) == 0, 0);
        let v1 = vpt(0, 3); let v2 = vpt(0, 1); assert!(diff(&v1, &v2, (456 as u256)) == 0, 0);
    }
}