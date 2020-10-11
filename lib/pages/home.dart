import 'package:ch13_local_presistence/classes/JournalEdit.dart';
import 'package:ch13_local_presistence/classes/journal.dart';
import 'package:ch13_local_presistence/pages/edit_entry.dart';
import 'package:flutter/material.dart';
import 'package:ch13_local_presistence/classes/database.dart';
import 'package:intl/intl.dart'; // Format Dates

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database _database;

  Future<List<Journal>> _loadJournals() async {
    await DatabaseFileRoutines().readJournals().then((journalsJson) {
      _database = databaseFromJson(journalsJson);
      _database.journal
          .sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
    });
    return _database.journal;
  }

  void _addOrEditJournal({bool add, int index, Journal journal}) async {
    JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
    _journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditEntry(
                add: add,
                index: index,
                journalEdit: _journalEdit,
              ),
          fullscreenDialog: true),
    );
    switch (_journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            _database.journal.add(_journalEdit.journal);
          });
        } else {
          setState(() {
            _database.journal[index] = _journalEdit.journal;
          });
        }
        DatabaseFileRoutines().writeJournals(databaseToJson(_database));
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  Widget _buildListViewSeperated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        String _titleDate = DateFormat.yMMMd()
            .format(DateTime.parse(snapshot.data[index].date));
        String _subtitle =
            snapshot.data[index].mood + "\n" + snapshot.data[index].note;
        return Dismissible(
          key: Key(snapshot.data[index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Column(
              children: <Widget>[
                Text(
                  DateFormat.d()
                      .format(DateTime.parse(snapshot.data[index].date)),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                      color: Colors.blue),
                ),
                Text(DateFormat.E()
                    .format(DateTime.parse(snapshot.data[index].date))),
              ],
            ),
            title: Text(
              _titleDate,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_subtitle),
            onTap: () {
              _addOrEditJournal(
                add: false,
                index: index,
                journal: snapshot.data[index],
              );
            },
          ),
          onDismissed: (direction) {
            setState(() {
              _database.journal.removeAt(index);
            });
            DatabaseFileRoutines().writeJournals(databaseToJson(_database));
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Local Persistence')),
      ),
      body: FutureBuilder(
          //inital data untuk menampilkan sebelum snapshot diambil.
          initialData: [],
          //memanggil async future method untuk mengambil data.
          future: _loadJournals(),
          /*jadi builder ini dia berupa buildcontext dan asyncsnapshot
          snapshot digunakan untuk mengambil dan memiliki data yang terupdate/ yang udah ditambahkan
          bisa dibilang asyncsnapshot itu ditugaskan untuk memberikan data terbaru dan status koneksi

          data snapshot tidak dapat di ubah" atau di modif, tetapi hanya dapat dibaca /read only

          untuk check apaka data sudah didapatkan atau dikembalikan, maka digunakan snapshot.hasdata, 
          untuk check connection state gunakan snapshot.connectionState connection state ini digunakan 
          untuk melihat apakah state aktif, menungggu, selesai atau tidak ada.

*/
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //jika snapshot tidak memiliki data maka dia
            return !snapshot.hasData
                //akan menjalankan loading animasi *circularprogressindicator
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                //jika snapshot memiliki data maka akan dibuatkan dan menampilkan list data
                : _buildListViewSeperated(snapshot);
          }),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
        ),
      ),
      //buat bikin tombol bulet di bawah tengah atau bawah kanan
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        child: Icon(Icons.add),
        onPressed: () {
          //ini tombol buat ngeadd atau ngedit
          _addOrEditJournal(add: true, index: -1, journal: Journal());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
