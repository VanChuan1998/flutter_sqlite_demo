import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sqlite_demo/app_config/text_config.dart';
import 'package:flutter_sqlite_demo/enum/load_satus.dart';
import 'package:flutter_sqlite_demo/model/student/person_entity.dart';
import 'package:flutter_sqlite_demo/repository/person_repository.dart';
import 'package:flutter_sqlite_demo/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());


  ///Mở database và check version
  Future<void> addData() async {
    emit(state.copyWith(loadDataStatus: LoadStatus.loading));
    try {
      String path = await PersonRepository.createDatabase(
          databaseName: TextConfig.myDatabase);
      Database database = await PersonRepository.open(
        path: path,
        version: state.currentDatabaseVersion,
      );
      final currentVersion = await PersonRepository.getVersion(db: database);
      if (currentVersion < (state.currentDatabaseVersion)) {
        emit(
          state.copyWith(
            databasePath: path,
            database: database,
            isOpenedDatabase: true,
            currentDatabaseVersion: currentVersion,
            loadDataStatus: LoadStatus.init,
          ),
        );
      } else {
        emit(
          state.copyWith(
            databasePath: path,
            database: database,
            isOpenedDatabase: true,
            currentDatabaseVersion: currentVersion,
            loadDataStatus: LoadStatus.success,
          ),
        );
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(loadDataStatus: LoadStatus.failure));
    }
  }

  ///Lấy ra tất cả data trong bảng person
  Future<void> getAllPerson() async {
    emit(state.copyWith(getDataStatus: LoadStatus.loading));
    try {
      if (state.database != null) {
        List<Person>? personList =
            await PersonRepository.getAllPerson(db: state.database!);
        emit(
          state.copyWith(
            personList: personList,
            getDataStatus: LoadStatus.success,
          ),
        );
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(getDataStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(getDataStatus: LoadStatus.failure));
    }
  }

  /// Lấy ra 1 phần tử trong bảng Person theo id
  void getPersonById({required int id}) async {
    emit(state.copyWith(getDataByIdStatus: LoadStatus.loading));
    try {
      if (state.database != null) {
        Person? person =
            await PersonRepository.getPerson(db: state.database!, id: id);
        emit(
          state.copyWith(
            person: person,
            getDataByIdStatus: LoadStatus.success,
          ),
        );
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(getDataByIdStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(getDataByIdStatus: LoadStatus.failure));
    }
  }

  /// Xoá 1 phần tử trong bảng Person theo id
  void deletePersonById(int id) async {
    emit(state.copyWith(getDataStatus: LoadStatus.loading));
    try {
      if (state.database != null) {
        final result =
            await PersonRepository.delete(db: state.database!, id: id);
        if (result != 0) {
          await getAllPerson();
          emit(
            state.copyWith(
              getDataStatus: LoadStatus.success,
            ),
          );
        }
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(getDataStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(getDataStatus: LoadStatus.failure));
    }
  }

  /// Thêm 1 phần tử trong bảng Person
  void insertPerson({
    required String name,
    required String age,
    String? address,
  }) async {
    emit(state.copyWith(insertDataStatus: LoadStatus.loading));
    try {
      if (state.database != null) {
        Person person = Person(
          age: int.tryParse(age),
          name: name,
          address: address,
        );
        final result =
            await PersonRepository.insert(person: person, db: state.database!);
        if (result != 0) {
          getAllPerson();
          emit(
            state.copyWith(
              insertDataStatus: LoadStatus.success,
            ),
          );
        } else {
          logger.e("Not inserted");
          emit(state.copyWith(insertDataStatus: LoadStatus.failure));
        }
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(insertDataStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(insertDataStatus: LoadStatus.failure));
    }
  }

  /// update 1 phần tử trong bảng Person
  void updatePerson({
     String? name,
     String? age,
     String? address,
    required int id,
  }) async {
    emit(state.copyWith(updateDataStatus: LoadStatus.loading));
    try {

      int? tuoi;
      if(age != null){
        tuoi = int.tryParse(age);
      }

      if (state.database != null) {
        Person person = Person(
          id: id,
          age: tuoi,
          name: name,
          address: address,
        );
        final result =
            await PersonRepository.update(person: person, db: state.database!);
        if (result != 0) {
          getAllPerson();
          emit(
            state.copyWith(
              updateDataStatus: LoadStatus.success,
            ),
          );
        } else {
          logger.e("Not updated");
          emit(state.copyWith(updateDataStatus: LoadStatus.failure));
        }
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(updateDataStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(updateDataStatus: LoadStatus.failure));
    }
  }

  /// thêm 1 cột trong bảng Person
  void addColumn() async {
    emit(state.copyWith(addColumnStatus: LoadStatus.loading));
    try {
      if (state.database != null) {
        await PersonRepository.queryDatabase(
          db: state.database!,
          sqlQuery:
              'ALTER TABLE ${TextConfig.personTable} ADD COLUMN address TEXT',
        );

        emit(
          state.copyWith(
            isAddAddressSuccess: true,
            currentDatabaseVersion: (state.currentDatabaseVersion ?? 1) + 1,
            addColumnStatus: LoadStatus.success,
          ),
        );
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(addColumnStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(addColumnStatus: LoadStatus.failure));
    }
  }

  /// xoá 1 cột trong bảng Person
  void deleteColumn() async {
    emit(state.copyWith(deleteColumnStatus: LoadStatus.loading));
    try {
      if (state.database != null) {
        ///Xoá 1 table dùng câu lệnh: DROP TABLE table_name
        await PersonRepository.queryDatabase(
          db: state.database!,
          sqlQuery: 'ALTER TABLE ${TextConfig.personTable} DROP COLUMN address',
        );

        emit(
          state.copyWith(
            isAddAddressSuccess: false,
            currentDatabaseVersion: (state.currentDatabaseVersion ?? 1) + 1,
            deleteColumnStatus: LoadStatus.success,
          ),
        );
      } else {
        logger.e("Database is empty");
        emit(state.copyWith(deleteColumnStatus: LoadStatus.failure));
      }
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(deleteColumnStatus: LoadStatus.failure));
    }
  }

  void showInsertData() {
    emit(state.copyWith(isShowInsertData: !state.isShowInsertData));
  }

  void showDataById() {
    emit(state.copyWith(isGetDataById: !state.isGetDataById));
  }

  void showData() {
    emit(state.copyWith(isShowData: !state.isShowData));
  }

  Future<void> closeDatabase() async{
    state.database?.close();
  }
}
