import 'package:adminkursus/src/model/banksoall_quicktype.dart';
import 'package:adminkursus/src/model/listbanksoal_model.dart';
import 'package:adminkursus/src/model/materi_model.dart';
import 'package:adminkursus/src/model/usernew_model.dart';
import 'package:firebase_database/firebase_database.dart';

class RealdbApi{
  static final FirebaseDatabase db = FirebaseDatabase.instance;
  final DatabaseReference ref = db.reference();

//----------------login custom------------------------------------------------

Future<UserNew> loginatorapi(String id,String pass)async{
 // var cek = ref.child('user/$pass');
  var cek2 = await ref.child('user/$id').once();
  print(cek2.value);
  if (cek2.value !=null){
    if (cek2.value["pass"]==pass){
      return UserNew.fromRealDb(cek2);
    }else{return null;}   
  }else{return null;}
}

Future<UserNew> getUserDetil(String id)async{
  print('get userdetil pre-processing...');
  return ref.child('user/$id').once().then((onValue)=>UserNew.fromRealDb(onValue));
}

//-----------------user admin------------------------------------
Future<List<UserNew>> getListUser()async{
  return ref.child('user').once().then((onValue){
    List<UserNew> litUser = List();
    (onValue.value as Map).forEach((k,v)=>litUser.add(UserNew.fromMap(v)));
   return litUser;
  });
}

Future<void> addUser(String id,String nama)async{
  return ref.child('user/$id').set(UserNew(
    id: id,
    nama: nama,
    createat: DateTime.now(),
    pass: id,
  ).toMap()).then((_)=>print('add user $id suksess isi dua'));
}

Future<void> editUser(String id,Map<String,dynamic> data)async{
  await ref.child('user/$id').set(data).then((_)=>print('update data user success'));
}

Future<void> deletUser(String id)async{
  return ref.child('user/$id').remove().then((_)=>print('remove user $id suksess isi dua'));
}

  //--------------------------------user googlesign-------------------------------------
  // Future<UserProfil> getUserProfil(String uid) async{
  //   return ref.child('user/$uid').once().then((val)=>UserProfil.fromrealdb(val));
  // }

  // Future<UserProfil> cekUser(FirebaseUser user) async{
  //   var snap = await ref.child('user/${user.uid}').once();
  //   print(snap.value);
  //   if (snap.value != null){
  //     print('data user ada');
  //     return UserProfil.fromrealdb(snap);
  //   }else{
  //     print('data user tidak ada');
  //      return createUser(user.uid, UserProfil(
  //       uid: user.uid,
  //       nama: user.displayName,
  //       email: user.email,
  //       kelas: null,
  //       urlimg: user.photoUrl,
  //       createat: DateTime.now()
  //     )).then((_)=>cekUser(user));
      
  //   }
  // }

  // Future<void> createUser(String uid,UserProfil data)async {
  //   return ref.child('user/$uid').set(data.toMap()).then((_)=>print('create user successfull'));
  // }
  // Future<void> updateUser(String uid,Map<String,dynamic> data){
  //   return ref.child('user/$uid').update(data).then((_)=>print('update user successfull'));
  // }

  //-------------------------------------soal-------------------------------------------------
  Future<List<Listbanksoal>> cariSoal(String kelas,String mapel) async{
    print('cari soal');
    var getdata =await  ref.child('carisoal/$kelas/$mapel').orderByChild("published").equalTo(true).once();
    Map coeg = getdata.value;
    print(coeg);
    List<Listbanksoal> list=[];
    if (coeg!=null){
      coeg.forEach((k,v)=>list.add(Listbanksoal.fromMap(k,v)));
    return list;
    }else{
      return null;
    }
  }

  Future<BanksoalModel> getBankSoalnya(String idsoal) async{
    print('getsoal func');
    DataSnapshot data =  await db.reference().child('/banksoal/$idsoal').once();
      print('getSoalnya:'+data.value.toString());
      return BanksoalModel.fromJson(data.key, data.value);
  }

  Future<List<Soalnye>> getSoalnye(String idsoal)async{
    return ref.child('banksoal/$idsoal/soalnye').once().then((onValue){
      return List<Soalnye>.from(onValue.value.map((x) => x == null ? null : Soalnye.fromJson(x)));
    });
  }
  Future<Selesai> getUserSelesaiDetil(String idsoal,String iduser)async{
    return ref.child('banksoal/$idsoal/selesai/$iduser').once().then((onValue){
      return Selesai.fromRealdb(onValue);
    });
  }

  Future<void> simpanJawaban(String idsoal,Map<String,dynamic> n,String uid,int nilai)async{
   return db.reference().child('banksoal/$idsoal/selesai/$uid').set({
      "uid":uid,
      "nilai":nilai,
      "tglselesai":DateTime.now().toIso8601String(),
      "jawabannye":n
    });    
  }

//--------------------------------------------------materi-------------------------------------------
Future<List<MateriModel>> getListMateri(String tingkat,String mapel)async{
  var data = await ref.child('materi/$tingkat/$mapel').orderByChild('published').equalTo(true).once();
  if (data.value!=null){
      Map oke =data.value;
      List<MateriModel> coeg=[];
      oke.forEach((k,v)=>coeg.add(MateriModel.fromMap(k,v)));
      return coeg;
      }else{return null;}
}
Future<List<MateriModel>> getListMateriAdmin(String tingkat,String mapel)async{
  var data = await ref.child('materi/$tingkat/$mapel').once();
  if (data.value!=null){
      Map oke =data.value;
      List<MateriModel> coeg=[];
      oke.forEach((k,v)=>coeg.add(MateriModel.fromMap(k,v)));
      return coeg;
      }else{return null;}
}
Future<void> buatmateri(MateriModel data)async{
  await ref.child('materi/${data.tingkat}/${data.mapel}').push().set(data.toMap());
}
Future<void> editmateri(MateriModel data)async{
  await ref.child('materi/${data.tingkat}/${data.mapel}/${data.id}').update(data.toMapEdit());
}
//------------------------------------------------------------admin----------------------------------

  Future<List<Listbanksoal>> getListSoal()async{
    var data = await ref.child('listbanksoal').once();
      print('get list soal:'+ data.value.toString());
      if (data.value!=null){
      Map oke =data.value;
      List<Listbanksoal> coeg=[];
      oke.forEach((k,v)=>coeg.add(Listbanksoal.fromMap(k,v)));
      return coeg;
      }else{return null;}
  }

  Future<void> setSoal(String idsoal,String no,Soalnye oke)async{
    return ref.child('banksoal/$idsoal/soalnye/$no').set(oke.toJson());
  }

  // Future<void> buatPaketSoal(Map<String,dynamic> data)async{
  //   return ref.child('banksoal').push().set(data).then((_)=>print("buat paket soal sukses, cus input"));
  // }

  Future<void> hapusPaketSoal(Listbanksoal data)async{
    await ref.child('banksoal/${data.id}').remove().then((_)=>print('hapus paket soal sukses')).then((_)async{
      await ref.child('carisoal/${data.kelas}/${data.mapel}/${data.id}').remove();
      await ref.child('listbanksoal/${data.id}').remove();
    });
  }

  // Future<void> pushPaketSoal(String kelas,String mapel, CariSoalModel sual)async{
  //   return ref.child('carisoal/$kelas/$mapel/${sual.idsoalnya}').set(sual.toMap()).then((_)=>print("push soal sukses")).then((_){
  //     return ref.child('banksoal/${sual.idsoalnya}/published').set(true).then((_)=>print('change published to true'));
  //   });
  // }

  // Future<void> unPublishSoal(String kelas,String mapel,String idpush,String idsoalnya)async{
  //   return ref.child('carisoal/$kelas/$mapel/$idpush').remove().then((_){
  //     return ref.child('banksoal/$idsoalnya/published').set(false).then((_)=>print('unpublish sukses'));
  //   });
  // }
//----------------------buat soal v2-------------------------------------------------------------

  Future<List<Listbanksoal>> cariSoalAdmin(String kelas,String mapel) async{
    print('cari soal');
    var getdata =await  ref.child('carisoal/$kelas/$mapel').once();
    Map coeg = getdata.value;
    print(coeg);
    List<Listbanksoal> list=[];
    if (coeg!=null){
      coeg.forEach((k,v)=>list.add(Listbanksoal.fromMap(k,v)));
    return list;
    }else{
      return null;
    }
  }

  Future<void> ngetesBuatSoalLangsungPushtapiFalse(Map<String,dynamic> data)async{
    var anu = ref.child('banksoal').push().key;
    var oke = data;
    oke["idsoal"] = anu;
    await ref.child('banksoal/$anu').set(data);
    await ref.child('carisoal/${data["kelas"]}/${data["mapel"]}/$anu').set(oke);
      // {
      // "published":false,
      // "tingkat":data["tingkat"],
      // "idsoal":anu,
      // "jenis":data["jenis"],
      // "titel":data["titel"]});
    await ref.child('listbanksoal/$anu').set(oke);
  }

  Future<void> publishSoaltrueV2({String kelas,String mapel, String idsoal})async{
    await ref.child('banksoal/$idsoal/published').set(true);
    await ref.child('carisoal/$kelas/$mapel/$idsoal/published').set(true);
    await ref.child('listbanksoal/$idsoal/published').set(true);
  }

  Future<void> unPublishSoalV2(String kelas,String mapel,String id)async{
    return ref.child('carisoal/$kelas/$mapel/$id/published').set(false).then((_)async{
      await ref.child('banksoal/$id/published').set(false).then((_)=>print('unpublish sukses'));
      await ref.child('listbanksoal/$id/published').set(false);
    });
  }

  // Future<List<CariSoalModel>> getlistDetilBanksoal()async{
  //   var getdata = await ref.child('listbanksoal').orderByChild('createat').once();
  //   Map coeg = getdata.value;
  //   print(coeg);
  //   List<CariSoalModel> list=[];
  //   if (coeg!=null){
  //     coeg.forEach((k,v)=>list.add(CariSoalModel.fromMap(k,v)));
  //   return list;
  //   }else{
  //     return null;
  //   }
  // }
  // Future<void> adddetilbanksoal(CariSoalModel data)async{
  //   await ref.child('listbanksoal/${data.id}').set(data.toMap());
  // }
  //-------------------------------------------materi--------------------------------------------------

  
}  