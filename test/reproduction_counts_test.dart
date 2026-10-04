import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/main.dart';

void main(){
  Map<String,dynamic> record()=>{
    'liveMaleBirth':5,'liveFemaleBirth':6,
    'deadMaleBirth':1,'deadFemaleBirth':2,
    'weaningDate':'04/10/2026',
    'deadMaleWeaning':1,'deadFemaleWeaning':1,
  };
  test('Deaths subtract once from the initial eleven births',(){
    final t=ReproductionStore.totals(record());
    expect(t['born'],11);expect(t['liveBirth'],8);
    expect(t['maleTotal'],4);expect(t['femaleTotal'],4);
    expect(t['weaned'],6);expect(t['weanedMale'],3);expect(t['weanedFemale'],3);
  });
  test('Missing weaning does not invent deaths',(){
    final r=record()..['weaningDate']='';
    final t=ReproductionStore.totals(r);
    expect(t['lossWeaning'],0);expect(t['liveBirth'],8);
    expect(ReproductionStore.countError(r),isNotNull);
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
