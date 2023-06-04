import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sqlite_demo/enum/load_satus.dart';
import 'package:flutter_sqlite_demo/view/home/home_cubit.dart';
import 'package:sqflite/sqflite.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late String databasePath = "";
  late Database database;
  late HomeCubit _cubit;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit();
  }

  @override
  void dispose() {
    _cubit.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter SQLite Demo'),
      ),
      body: SingleChildScrollView(
        child: BlocConsumer<HomeCubit, HomeState>(
          bloc: _cubit,
          listenWhen: (prev, curr) =>
              prev.isOutdatedDBVersion != curr.isOutdatedDBVersion,
          listener: (context, state) {
            if (state.isOutdatedDBVersion) {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                // false = user must tap button, true = tap outside dialog
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Thông báo'),
                    content: const Text(
                        'Phiên bản hiện tại đã quá lỗi thời. Vui lòng cập nhật lên phiên bản mới nhất'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          //todo
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          buildWhen: (prev, curr) =>
              prev.isShowData != curr.isShowData ||
              prev.isOpenedDatabase != curr.isOpenedDatabase ||
              prev.isGetDataById != curr.isGetDataById ||
              prev.isShowInsertData != curr.isShowInsertData,
          builder: (context, state) {
            return Column(
              children: [
                state.isOpenedDatabase
                    ? const SizedBox()
                    : BlocListener<HomeCubit, HomeState>(
                        bloc: _cubit,
                        listenWhen: (prev, curr) =>
                            prev.loadDataStatus != curr.loadDataStatus,
                        listener: (context, state) {
                          switch (state.loadDataStatus) {
                            case LoadStatus.success:
                              showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                // false = user must tap button, true = tap outside dialog
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Thông báo'),
                                    content:
                                        const Text('Mở Database thành công'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // Dismiss alert dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              break;
                            case LoadStatus.failure:
                              showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                // false = user must tap button, true = tap outside dialog
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Thông báo'),
                                    content: const Text('Mở Database thất bại'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // Dismiss alert dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              break;
                            default:
                              break;
                          }
                        },
                        child: ElevatedButton(
                            onPressed: () {
                              _cubit.addData();
                            },
                            child: const Text("Open Database")),
                      ),
                ElevatedButton(
                    onPressed: () {
                      _cubit.showInsertData();
                    },
                    child: const Text("Insert Data")),
                state.isShowInsertData ? _inputDataWidget() : const SizedBox(),
                ElevatedButton(
                    onPressed: () {
                      _cubit.showData();
                      _cubit.getAllPerson();
                    },
                    child: const Text("Show Data")),
                state.isShowData ? _getAllDataWidget() : const SizedBox(),
                ElevatedButton(
                    onPressed: () {
                      _cubit.showDataById();
                    },
                    child: const Text("Get Person by Id")),
                state.isGetDataById ? _getDataByIdWidget() : const SizedBox(),
                BlocListener<HomeCubit, HomeState>(
                  bloc: _cubit,
                  listenWhen: (prev, curr) =>
                      prev.addColumnStatus != curr.addColumnStatus,
                  listener: (context, state) {
                    switch (state.addColumnStatus) {
                      case LoadStatus.success:
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Thông báo'),
                              content: const Text('Thêm Colume thành công'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () async {
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog
                                    await _cubit.closeDatabase();
                                    _cubit.addData();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        break;
                      case LoadStatus.failure:
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Thông báo'),
                              content: const Text('Thêm Colume thất bại'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        break;
                      default:
                        break;
                    }
                  },
                  child: ElevatedButton(
                      onPressed: () {
                        _cubit.addColumn();
                      },
                      child: const Text("Add Address column")),
                ),
                BlocListener<HomeCubit, HomeState>(
                  bloc: _cubit,
                  listenWhen: (prev, curr) =>
                      prev.deleteColumnStatus != curr.deleteColumnStatus,
                  listener: (context, state) {
                    switch (state.deleteColumnStatus) {
                      case LoadStatus.success:
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Thông báo'),
                              content: const Text('Xoá Colume thành công'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () async {
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog
                                    await _cubit.closeDatabase();
                                    _cubit.addData();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        break;
                      case LoadStatus.failure:
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Thông báo'),
                              content: const Text('Xoá Colume thất bại'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        break;
                      default:
                        break;
                    }
                  },
                  child: ElevatedButton(
                      onPressed: () {
                        _cubit.deleteColumn();
                      },
                      child: const Text("Delete Address column")),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _inputDataWidget() {
    return BlocConsumer<HomeCubit, HomeState>(
      bloc: _cubit,
      listenWhen: (prev, curr) =>
          prev.insertDataStatus != curr.insertDataStatus,
      listener: (context, state) {
        switch (state.insertDataStatus) {
          case LoadStatus.success:
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Thêm thông tin thành công'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        nameController.text = '';
                        ageController.text = '';
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    ),
                  ],
                );
              },
            );
            break;
          case LoadStatus.failure:
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Thêm thông tin thất bại'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    ),
                  ],
                );
              },
            );
            break;
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          prev.isAddAddressSuccess != curr.isAddAddressSuccess,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tên'),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
              ),
              const SizedBox(height: 5),
              const Text('Tuổi'),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
              ),
              const SizedBox(height: 5),
              // const Text('Địa chỉ'),
              // TextFormField(
              //         controller: addressController,
              //         decoration: const InputDecoration(
              //             contentPadding: EdgeInsets.symmetric(
              //                 horizontal: 10, vertical: 10)),
              //       ),
              const SizedBox(height: 5),
              ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        ageController.text.isEmpty) {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        // false = user must tap button, true = tap outside dialog
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Thông báo'),
                            content:
                                const Text('Tên hoặc Tuổi không được đề trống'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(dialogContext)
                                      .pop(); // Dismiss alert dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      _cubit.insertPerson(
                        name: nameController.text,
                        age: ageController.text,
                        address: addressController.text,
                      );
                    }
                  },
                  child: const Text("Insert")),
            ],
          ),
        );
      },
    );
  }

  Widget _getDataByIdWidget() {
    return BlocListener<HomeCubit, HomeState>(
      bloc: _cubit,
      listenWhen: (prev, curr) =>
          prev.getDataByIdStatus != curr.getDataByIdStatus ||
          prev.isAddAddressSuccess != curr.isAddAddressSuccess,
      listener: (context, state) {
        if (state.getDataByIdStatus == LoadStatus.success) {
          showDialog<void>(
            context: context,
            barrierDismissible: true,
            // false = user must tap button, true = tap outside dialog
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Kết quả'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ID: ${state.person?.id}    ${state.person?.name}'),
                    Text('Age: ${state.person?.age}'),
                    // Text('Address: ${state.person?.address}'),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      idController.clear();
                      Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ID'),
            TextFormField(
              controller: idController,
              decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
                onPressed: () {
                  if (idController.text.isEmpty) {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      // false = user must tap button, true = tap outside dialog
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Thông báo'),
                          content: const Text('ID không được đề trống'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Dismiss alert dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _cubit.getPersonById(
                        id: (int.tryParse(idController.text) ?? 0));
                  }
                },
                child: const Text("Get")),
          ],
        ),
      ),
    );
  }

  Widget _getAllDataWidget() {
    return BlocConsumer<HomeCubit, HomeState>(
      bloc: _cubit,
      listenWhen: (prev, curr) =>
          prev.updateDataStatus != curr.updateDataStatus,
      listener: (context, state) {
        switch (state.updateDataStatus) {
          case LoadStatus.success:
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Cập nhật thông tin thành công'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        nameController.text = '';
                        ageController.text = '';
                        addressController.text = '';
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    ),
                  ],
                );
              },
            );
            break;
          case LoadStatus.failure:
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Cập nhật thông tin thất bại'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    ),
                  ],
                );
              },
            );
            break;
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          prev.getDataStatus != curr.getDataStatus ||
          prev.isAddAddressSuccess != curr.isAddAddressSuccess,
      builder: (context, state) {
        switch (state.getDataStatus) {
          case LoadStatus.loading:
            return const CircularProgressIndicator();
          case LoadStatus.failure:
            return const Center(
              child: Text("Lỗi"),
            );
          default:
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.personList.length,
              itemBuilder: (context, index) {
                final person = state.personList[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text("ID: ${(person.id ?? 0).toString()}"),
                      const SizedBox(width: 10),
                      Text(person.name ?? ''),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      Text('Age: ${person.age ?? ''}'),
                      // Text('Address: ${person.address ?? ''}'),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        // false = user must tap button, true = tap outside dialog
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Edit'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Tên'),
                                  TextFormField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10)),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text('Tuổi'),
                                  TextFormField(
                                    controller: ageController,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10)),
                                  ),
                                  const SizedBox(height: 5),
                                  // const Text('Địa chỉ'),
                                  // TextFormField(
                                  //         controller: ageController,
                                  //         decoration: const InputDecoration(
                                  //             contentPadding:
                                  //                 EdgeInsets.symmetric(
                                  //                     horizontal: 10,
                                  //                     vertical: 10)),
                                  //       ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  String name = person.name ?? '';
                                  if (nameController.text.isNotEmpty) {
                                    name = nameController.text;
                                  }
                                  String age = person.age.toString();
                                  if (ageController.text.isNotEmpty) {
                                    age = ageController.text;
                                  }

                                  _cubit.updatePerson(
                                    id: person.id ?? 0,
                                    name: name,
                                    age: age,
                                  );
                                  Navigator.of(dialogContext)
                                      .pop(); // Dismiss alert dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                      _cubit.deletePersonById(person.id ?? 0);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _cubit.deletePersonById(person.id ?? 0);
                    },
                  ),
                );
              },
            );
        }
      },
    );
  }
}
