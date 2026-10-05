import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/main.dart';
void main(){
  final now=DateTime(2026,10,5,12);
  Map<String,dynamic> female()=>{'id':'f','medications':[]};
  List<String> reasons(Map<String,dynamic> f,List<Map<String,dynamic>> r,{int max=1,int rest=90})=>
    ReproductionAvailability.reasons(female:f,records:r,maxLitters:max,restDays:rest,now:now);
  test('Active treatment with no end, future start and expired treatment',(){
    final f=female()..['medications']=[{'startDate':'01/10/2026','endDate':''}];
    expect(reasons(f,[]).single,contains('Traitement médical actif'));
    f['medications']=[{'startDate':'06/10/2026','endDate':''}];expect(reasons(f,[]),isEmpty);
    f['medications']=[{'startDate':'01/10/2026','endDate':'04/10/2026'}];expect(reasons(f,[]),isEmpty);
    f['medications']=[{'startDate':'01/10/2026','endDate':'05/10/2026'}];expect(reasons(f,[]).length,1);
  });
  test('Rest boundary and other females do not restrict this female',(){
    final date=Notifications.formatDate(now.subtract(const Duration(days:89)));
    final r=[{'femaleId':'f','birthDate':date}];
    expect(reasons(female(),r,max:4).single,contains('1 jour(s) restant(s)'));
    r.first['birthDate']=Notifications.formatDate(now.subtract(const Duration(days:90)));
    expect(reasons(female(),r,max:4),isEmpty);
    r.first['femaleId']='other';expect(reasons(female(),r),isEmpty);
  });
  test('Annual quota reached, cutoff included and old births excluded',(){
    final r=[{'femaleId':'f','birthDate':Notifications.formatDate(now.subtract(const Duration(days:365)))}];
    // Original rule uses an exact 365-day cutoff; use midnight to test equality.
    final atMidnight=DateTime(2026,10,5);
    expect(ReproductionAvailability.reasons(female:female(),records:r,maxLitters:1,restDays:0,now:atMidnight).single,contains('Quota annuel atteint'));
    r.first['birthDate']=Notifications.formatDate(now.subtract(const Duration(days:366)));
    expect(reasons(female(),r,rest:0),isEmpty);
  });
  test('All reasons accumulate; matching history is untouched',(){
    final f=female()..['medications']=[{'startDate':'01/10/2026','endDate':''}];
    final r=[{'femaleId':'f','birthDate':'02/10/2026'}];
    final result=reasons(f,r);
    expect(result.length,3);expect(result.any((s)=>s.contains('Traitement')),isTrue);
    expect(result.any((s)=>s.contains('Quota')),isTrue);expect(result.any((s)=>s.contains('repos')),isTrue);
    expect(r.single['birthDate'],'02/10/2026');
  });
}
