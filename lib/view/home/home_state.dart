part of 'home_cubit.dart';

class HomeState extends Equatable {
  final LoadStatus loadDataStatus;
  final LoadStatus insertDataStatus;
  final LoadStatus updateDataStatus;
  final LoadStatus getDataStatus;
  final LoadStatus getDataByIdStatus;
  final LoadStatus addColumnStatus;
  final LoadStatus deleteColumnStatus;

  final Database? database;
  final String databasePath;
  final List<Person> personList;
  final Person? person;
  final int currentDatabaseVersion;

  final bool isOpenedDatabase;
  final bool isShowInsertData;
  final bool isShowData;
  final bool isGetDataById;
  final bool isOutdatedDBVersion;
  final bool isAddAddressSuccess;

  const HomeState({
    this.loadDataStatus = LoadStatus.init,
    this.insertDataStatus = LoadStatus.init,
    this.updateDataStatus = LoadStatus.init,
    this.getDataStatus = LoadStatus.init,
    this.getDataByIdStatus = LoadStatus.init,
    this.addColumnStatus = LoadStatus.init,
    this.deleteColumnStatus = LoadStatus.init,
    this.database,
    this.databasePath = '',
    this.personList = const [],
    this.person,
    this.currentDatabaseVersion = 1,
    this.isOpenedDatabase = false,
    this.isShowInsertData = false,
    this.isGetDataById = false,
    this.isShowData = false,
    this.isOutdatedDBVersion = false,
    this.isAddAddressSuccess = false,
  });

  HomeState copyWith({
    LoadStatus? loadDataStatus,
    LoadStatus? insertDataStatus,
    LoadStatus? updateDataStatus,
    LoadStatus? getDataStatus,
    LoadStatus? getDataByIdStatus,
    LoadStatus? addColumnStatus,
    LoadStatus? deleteColumnStatus,
    Database? database,
    String? databasePath,
    List<Person>? personList,
    Person? person,
    int? currentDatabaseVersion,
    bool? isOpenedDatabase,
    bool? isShowInsertData,
    bool? isGetDataById,
    bool? isShowData,
    bool? isOutdatedDBVersion,
    bool? isAddAddressSuccess,
  }) =>
      HomeState(
        loadDataStatus: loadDataStatus ?? this.loadDataStatus,
        insertDataStatus: insertDataStatus ?? this.insertDataStatus,
        updateDataStatus: updateDataStatus ?? this.updateDataStatus,
        getDataStatus: getDataStatus ?? this.getDataStatus,
        getDataByIdStatus: getDataByIdStatus ?? this.getDataByIdStatus,
        addColumnStatus: addColumnStatus ?? this.addColumnStatus,
        deleteColumnStatus: deleteColumnStatus ?? this.deleteColumnStatus,
        database: database ?? this.database,
        databasePath: databasePath ?? this.databasePath,
        personList: personList ?? this.personList,
        person: person ?? this.person,
        currentDatabaseVersion: currentDatabaseVersion ?? this.currentDatabaseVersion,
        isOpenedDatabase: isOpenedDatabase ?? this.isOpenedDatabase,
        isShowInsertData: isShowInsertData ?? this.isShowInsertData,
        isGetDataById: isGetDataById ?? this.isGetDataById,
        isShowData: isShowData ?? this.isShowData,
        isOutdatedDBVersion: isOutdatedDBVersion ?? this.isOutdatedDBVersion,
        isAddAddressSuccess: isAddAddressSuccess ?? this.isAddAddressSuccess,
      );

  @override
  // TODO: implement props
  List<Object?> get props => [
        loadDataStatus,
        insertDataStatus,
        updateDataStatus,
        getDataStatus,
        getDataByIdStatus,
        addColumnStatus,
        deleteColumnStatus,
        database,
        databasePath,
        personList,
        person,
        currentDatabaseVersion,
        isOpenedDatabase,
        isShowInsertData,
        isGetDataById,
        isShowData,
        isOutdatedDBVersion,
        isAddAddressSuccess,
      ];
}
