import 'package:pocketree/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({
    String email,
    String password,
  }); 
}

// import 'package:dio/dio.dart';

// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   final Dio dio;

//   AuthRemoteDataSourceImpl(this.dio);

//   @override
//   Future<UserModel> login(String email, String password) async {
//     final response = await dio.post(
//       '/auth/login',
//       data: {
//         'email': email,
//         'password': password,
//       },
//     );

//     return UserModel.fromJson(response.data);
//   }
// }