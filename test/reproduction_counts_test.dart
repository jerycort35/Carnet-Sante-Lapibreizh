import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/main.dart';

void main(){
  Map<String,dynamic> record()=>{
    'liveMaleBirth':5,'liveFemaleBirth':6,
    'deadMaleBirth':1,'deadFemaleBirth':2,
    'weaningDate':'04/10/2026',
    'deadMaleWeaning':1,'deadFemaleWeaning':1,
  };
  test('Screenshot: colors of six remaining males and four females are valid',(){
    final r={'liveMaleBirth':8,'liveFemaleBirth':4,'deadMaleBirth':1,'deadFemaleBirth':0,
      'deadMaleWeaning':1,'deadFemaleWeaning':0,'weaningDate':'02/07/2026',
      'colors':[{'color':'Noir','male':4,'female':4},{'color':'Noir uni','male':2,'female':0}]};
    expect(ReproductionStore.colorCountBasis(r),'remaining');
    expect(ReproductionStore.totals(r)['remaining'],10);
    r['colors']=[{'color':'Noir','male':5,'female':4},{'color':'Noir uni','male':2,'female':0}];
    expect(ReproductionStore.colorCountBasis(r),'birth');
    r['colors']=[{'color':'Noir','male':5,'female':4}];
    expect(ReproductionStore.colorCountBasis(r),isNull);
  });
  test('Color distributions must match both sexes at the same stage',(){
    final r=record()..['colors']=[{'color':'Noir','male':4,'female':3}];
    expect(ReproductionStore.colorCountBasis(r),isNull);
    r['colors']=[{'color':'Noir','male':3,'female':3}];
    expect(ReproductionStore.colorCountBasis(r),'remaining');
    r['colors']=[];expect(ReproductionStore.colorCountBasis(r),'none');
  });
  test('Deaths subtract once from the initial eleven births',(){
    final t=ReproductionStore.totals(record());
    expect(t['born'],11);expect(t['liveBirth'],8);
    expect(t['liveMale'],4);expect(t['liveFemale'],4);
    expect(t['maleTotal'],3);expect(t['femaleTotal'],3);expect(t['remaining'],6);
    expect(t['weaned'],6);expect(t['weanedMale'],3);expect(t['weanedFemale'],3);
  });
  test('Declared weaning deaths subtract immediately even without a date',(){
    final r=record()..['weaningDate']='';
    final t=ReproductionStore.totals(r);
    expect(t['lossWeaning'],2);expect(t['liveBirth'],8);expect(t['remaining'],6);
    expect(t['weaned'],6);expect(ReproductionStore.countError(r),isNull);
  });
  test('Unrecorded weaning never invents deaths',(){
    final r=record()..['weaningDate']=''..remove('deadMaleWeaning')..remove('deadFemaleWeaning');
    expect(ReproductionStore.totals(r)['remaining'],8);
    expect(ReproductionStore.totals(r)['lossWeaning'],0);
  });
  test('Each additional sex-specific death reduces remaining survivors once',(){
    final r=record();
    expect(ReproductionStore.totals(r)['remaining'],6);
    r['deadMaleWeaning']=2;
    expect(ReproductionStore.totals(r)['remaining'],5);
    expect(ReproductionStore.totals(r)['remainingMale'],2);
    expect(ReproductionStore.totals(r)['remainingFemale'],3);
    r['deadFemaleWeaning']=3;
    final t=ReproductionStore.totals(r);
    expect(t['remaining'],3);expect(t['remainingFemale'],1);
    expect(t['born'],11);expect(t['liveBirth'],8);
    r['liveMaleWeaning']=t['weanedMale'];r['liveFemaleWeaning']=t['weanedFemale'];
    expect(ReproductionStore.totals(r),t);
  });
  test('Reject deaths exceeding the same-sex population',(){
    expect(ReproductionStore.countError(record()..['deadMaleBirth']=6),isNotNull);
    expect(ReproductionStore.countError(record()..['deadFemaleWeaning']=5),isNotNull);
    expect(ReproductionStore.countError(record()),isNull);
  });
  test('Older weaning survivor counts infer losses without adding deaths',(){
    final r=record()..remove('deadMaleWeaning')..remove('deadFemaleWeaning');
    r['liveMaleWeaning']=3;r['liveFemaleWeaning']=2;
    final t=ReproductionStore.totals(r);
    expect(t['weaned'],5);expect(t['lossWeaning'],3);
  });
  test('Aggregate computes each litter before summing; profiles exclude deaths',(){
    final t=ReproductionStore.totals(ReproductionStore.aggregate([record(),record()]));
    expect(t['born'],22);expect(t['liveBirth'],16);expect(t['weaned'],12);
    final p=ReproductionStore.sexProfile([record()]);
    expect(p['male'],50);expect(p['female'],50);
  });
  test('Defensive display never produces negative survivors',(){
    final t=ReproductionStore.totals(record()..['deadMaleBirth']=99..['deadFemaleWeaning']=99);
    expect(t['liveMale'],0);expect(t['weanedFemale'],0);
  });
}
