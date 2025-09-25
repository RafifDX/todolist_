// Import library Flutter untuk UI components
import 'package:flutter/material.dart';

// Model class untuk Task = blueprint/template untuk objek Task
class Task {
  // Property untuk menyimpan judul task
  String title;
  // Property untuk menyimpan status selesai/belum
  bool isCompleted;

  // Constructor = function untuk membuat Task baru
  Task({
    // title wajib diisi (required)
    required this.title,
    // isCompleted opsional, default false (belum selesai)
    this.isCompleted = false,
  });

  // Method untuk toggle status completed (true ↔ false)
  void toggle() {
    // Flip boolean: true jadi false, false jadi true
    isCompleted = !isCompleted;
  }

  // Override toString untuk debug print yang readable
  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

// Function utama yang dijalankan pertama kali
void main() {
  // Jalankan aplikasi Flutter, dimulai dari widget MyApp
  runApp(const MyApp());
}

// Deklarasi class MyApp yang extends (turunan dari) StatelessWidget
class MyApp extends StatelessWidget {
  // Constructor dengan key parameter untuk best practices
  const MyApp({super.key});

  // Override function build yang WAJIB ada di setiap widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nama aplikasi (muncul di task switcher)
      title: 'Todo App Pemula',
      // Tema warna aplikasi
      theme: ThemeData(
        // Warna utama aplikasi = biru
        primarySwatch: Colors.blue,
      ),
      // Halaman pertama yang ditampilkan saat app dibuka
      home: const TodoListScreen(),
    );
  }
}

// Deklarasi class TodoListScreen untuk halaman utama
class TodoListScreen extends StatefulWidget {
  // Constructor dengan key parameter untuk best practices
  const TodoListScreen({super.key});

  // Override method untuk membuat state object
  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

// State class yang menyimpan data dan build UI
// State class dengan variables untuk menyimpan data
class _TodoListScreenState extends State<TodoListScreen> {
  // State variables = data yang bisa berubah
  // List untuk menyimpan objek Task (bukan String lagi)
  List<Task> tasks = [];
  // Controller untuk mengontrol TextField (ambil text, clear, dll)
  TextEditingController taskController = TextEditingController();

  // Helper function untuk statistic items
  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Function untuk menambah task baru ke dalam list
  void addTask() {
    // Ambil dan bersihkan input text
    String newTaskTitle = taskController.text.trim();

    // Validasi 1: Cek apakah input kosong
    if (newTaskTitle.isEmpty) {
      // Tampilkan SnackBar warning untuk input kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Content dengan icon dan text
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Task tidak boleh kosong!'),
            ],
          ),
          // Styling SnackBar
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Stop execution jika gagal validasi
      return;
    }

    // Validasi 2: Cek task duplikat (case insensitive)
    bool isDuplicate = tasks.any((task) =>
        task.title.toLowerCase() == newTaskTitle.toLowerCase());

    if (isDuplicate) {
      // SnackBar untuk task duplikat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              // Expanded agar text tidak overflow
              Expanded(child: Text('Task "$newTaskTitle" sudah ada!')),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi 3: Cek panjang task maksimal 100 karakter
    if (newTaskTitle.length > 100) {
      // SnackBar untuk task terlalu panjang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task terlalu panjang! Maksimal 100 karakter.')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Semua validasi passed - add task
    setState(() {
      Task newTask = Task(title: newTaskTitle);
      tasks.add(newTask);
    });

    // Clear input
    taskController.clear();

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Task "$newTaskTitle" berhasil ditambahkan!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('Task ditambahkan: $newTaskTitle');
  }

  void removeTask(int index) async {
    // Simpan nama task yang akan dihapus untuk ditampilkan di dialog
    Task taskToDelete = tasks[index];
    // Tampilkan dialog konfirmasi dan tunggu response user
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      // Builder function untuk membuat content dialog
      builder: (BuildContext context) {
        // AlertDialog = popup konfirmasi
        return AlertDialog(
          // Title dialog dengan icon warning
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          // Content dialog
          content: Column(
            // Column sekecil mungkin
            mainAxisSize: MainAxisSize.min,
            // Align kiri
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text pertanyaan
              const Text('Apakah kamu yakin ingin menghapus task ini?'),
              const SizedBox(height: 12),
              // Container untuk preview task yang akan dihapus
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                // Preview task dalam tanda kutip
                child: Text(
                  '"${taskToDelete.title}"', // Akses .title property
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Actions = tombol-tombol di bawah dialog
          actions: [
            // Tombol Batal
            TextButton(
              // Tutup dialog dan return false
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            // Tombol Hapus
            ElevatedButton(
              // Tutup dialog dan return true
              onPressed: () => Navigator.of(context).pop(true),
              // Styling button merah
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Cek apakah user pilih hapus (shouldDelete == true)
    if (shouldDelete == true) {
      setState(() {
        tasks.removeAt(index);
      });

      // Success feedback for delete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task "${taskToDelete.title}" dihapus')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('Task dihapus: ${taskToDelete.title}');
      // Debug print
      debugPrint('Task dihapus: $taskToDelete');
      debugPrint('Sisa tasks: ${tasks.length}');
    } else {
      debugPrint('Delete dibatalkan');
    }
  }

  // Function untuk toggle status completed
  void toggleTask(int index) {
    setState(() {
      tasks[index].toggle();
    });

    Task task = tasks[index];
    String message = task.isCompleted
        ? 'Selamat! Task "${task.title}" selesai! 🎉'
        : 'Task "${task.title}" ditandai belum selesai';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.celebration : Icons.undo,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: task.isCompleted ? Colors.green : Colors.blue,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    print('Task ${task.isCompleted ? "completed" : "uncompleted"}: ${task.title}');
  }

  // Override dispose untuk cleanup controller saat widget dihancurkan
  @override
  void dispose() {
    // Cleanup TextEditingController untuk prevent memory leaks
    taskController.dispose();
    // Call parent dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return UI yang sama seperti Tahap 2
    return Scaffold(
      // AppBar di bagian atas
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blue,
      ),
      // Body dengan padding di semua sisi
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Column untuk layout vertikal
        child: Column(
          children: [
            // Container untuk area input form
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              // Column di dalam container
              child: Column(
                children: [
                  // TextField dengan controller untuk ambil input user
                  TextField(
                    controller: taskController,
                    textCapitalization: TextCapitalization.sentences, // Auto capitalize
                    maxLength: 100, // Limit input length
                    decoration: InputDecoration(
                      hintText: 'Ketik task baru di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.edit),
                      counterText: '', // Hide character counter
                      helperText: 'Maksimal 100 karakter', // Helper text
                    ),
                    onSubmitted: (value) => addTask(), // Enter key also adds task
                  ),
                  // Jarak vertikal
                  const SizedBox(height: 12),
                  // Container untuk button
                  SizedBox(
                    width: double.infinity,
                    // Button untuk add task
                    child: ElevatedButton(
                      // Action saat button ditekan
                      // Alternative: panggil function di dalam anonymous function
                      onPressed: () {
                        // Call function addTask
                        addTask();
                      },
                      // Styling button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      // Isi button: Row dengan icon dan text
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text(
                            'Add Task',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Jarak vertikal setelah form
            SizedBox(height: 20),

            // Statistics card - hanya tampil jika ada tasks
            if (tasks.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Statistik Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total', tasks.length, Icons.list, Colors.blue),
                        _buildStatItem(
                          'Selesai',
                          tasks.where((task) => task.isCompleted).length,
                          Icons.check_circle,
                          Colors.green
                        ),
                        _buildStatItem(
                          'Belum',
                          tasks.where((task) => !task.isCompleted).length,
                          Icons.pending,
                          Colors.orange
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Text yang menampilkan jumlah tasks
            Text(
              // Conditional text berdasarkan apakah list kosong atau tidak
              tasks.isEmpty
                ? 'Belum ada task. Yuk tambah yang pertama!'
                : 'Kamu punya ${tasks.length} task${tasks.length > 1 ? 's' : ''}',
              // Styling text
              style: TextStyle(
                fontSize: 16,
                // Warna berbeda: abu jika kosong, biru jika ada isi
                color: tasks.isEmpty ? Colors.grey[600] : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Jarak vertikal sebelum area list
            const SizedBox(height: 20),
            
            // Expanded mengambil sisa ruang yang tersedia di Column
            Expanded(
              // Container untuk styling area list
              child: Container(
                // Lebar penuh
                width: double.infinity,
                // Padding di dalam container
                padding: const EdgeInsets.all(16),
                // Dekorasi container: border dan border radius
                decoration: BoxDecoration(
                  // Border abu-abu di sekeliling
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  // Sudut melengkung
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Conditional rendering: tampil berbeda jika kosong vs ada isi
                child: tasks.isEmpty
                  ? // Tampilan jika list kosong
                    Center(
                      // Column untuk susun icon dan text vertikal
                      child: Column(
                        // Center semua content di tengah
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon inbox kosong
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          // Jarak vertikal
                          const SizedBox(height: 16),
                          // Text utama
                          Text(
                            'Belum ada task',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Jarak kecil
                          const SizedBox(height: 8),
                          // Text penjelasan
                          Text(
                            'Tambahkan task pertamamu di atas!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : // Tampilan jika ada tasks: ListView untuk scroll
                    ListView.builder(
                      physics: BouncingScrollPhysics(), // iOS-style bounce
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        Task task = tasks[index]; // Ambil Task object

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              // Background berubah berdasarkan status
                              color: task.isCompleted ? Colors.green[50] : Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: task.isCompleted
                                  ? Border.all(color: Colors.green[200]!, width: 2) // Border hijau jika selesai
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: task.isCompleted ? 0.7 : 1.0, // Completed task lebih transparan
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    // Warna berubah berdasarkan status
                                    color: task.isCompleted ? Colors.green[100] : Colors.blue[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: task.isCompleted
                                        ? Icon(Icons.check, color: Colors.green[700]) // Icon check jika selesai
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  task.title, // Akses .title dari Task object
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                                    // STRIKETHROUGH untuk completed task
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  task.isCompleted ? 'Selesai ✅' : 'Belum selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.isCompleted ? Colors.green[600] : Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // CHECKBOX untuk toggle complete
                                    IconButton(
                                      icon: Icon(
                                        task.isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: task.isCompleted ? Colors.green[600] : Colors.grey[400],
                                      ),
                                      onPressed: () => toggleTask(index),
                                      tooltip: task.isCompleted
                                          ? 'Mark as incomplete'
                                          : 'Mark as complete',
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                                      onPressed: () => removeTask(index),
                                      tooltip: 'Hapus task',
                                    ),
                                  ],
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                // Tap pada item juga bisa toggle
                                onTap: () => toggleTask(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}