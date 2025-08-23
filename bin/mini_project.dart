// for json decode
import 'dart:convert';
// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';

void main() async {
  expense();
}

login() async {
  while (true) {
    print("==== Login ====");
    stdout.write("Username: ");
    String? username = stdin.readLineSync()?.trim();
    stdout.write("Password: ");
    String? password = stdin.readLineSync()?.trim();
    if (username == null || password == null) {
      print("Incomplete input");
      return;
    }

    final body = {"username": username, "password": password};
    final url = Uri.parse('http://localhost:3000/login');
    final response = await http.post(url, body: body);
    if (response.statusCode == 200) {
      final result = response.body;
      return result;
    } else if (response.statusCode == 401 || response.statusCode == 500) {
      final result = response.body;
      print(result);
    } else {
      print("Unknown error");
    }
  }
}

expense() async {
  dynamic id = await login();
  while (true) {
    print("========= Expense Tracking App =========");
    print("1. Show all");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");
    stdout.write("Choose...");
    String? choise = stdin.readLineSync()?.trim();
    switch (choise) {
      case "1": //All expense
        final url = Uri.parse('http://localhost:3000/expense/0');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final result = json.decode(response.body) as List;
          int total = 0;
          print("------------- All expenses ----------");
          for (int i = 0; i < result.length; i++) {
            final dt = DateTime.parse(result[i]['date']);
            final dtLocal = dt.toLocal();
            print(
              "${result[i]['id']}. ${result[i]['item']} : ${result[i]['paid']}฿ : ${dtLocal.toString()}",
            );
            total += result[i]['paid'] as int;
          }
          print("Total expenses = $total฿");
        }
        print('');
        break;
      case "2": //Today's expense
        final url = Uri.parse('http://localhost:3000/expense/$id');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final result = json.decode(response.body) as List;
          int total = 0;
          print("------------- Today's expenses ----------");
          for (var item in result) {
            final dt = DateTime.parse(item['date']);
            final dtLocal = dt.toLocal();
            print(
              "${item['id']}. ${item['item']} : ${item['paid']}฿ : ${dtLocal.toString()}",
            );
            total += item['paid'] as int;
          }
          print("Total expenses = $total฿");
        }
        print('');
        break;
      case "3": //Search expense
        stdout.write("Enter keyword to search: ");
        String? keyword = stdin.readLineSync()?.trim();

        if (keyword == null || keyword.isEmpty) {
          print("Please enter a valid keyword.");
          break;
        }

        final url = Uri.parse(
          'http://localhost:3000/search/$keyword',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final result = json.decode(response.body) as List;
          if (result.isEmpty) {
            print("No expenses found for keyword: $keyword");
          } else {
            int total = 0;
            print("------------- Search results ----------");
            for (var item in result) {
              final dt = DateTime.parse(item['date']);
              final dtLocal = dt.toLocal();
              print(
                "${item['id']}. ${item['item']} : ${item['paid']}฿ : ${dtLocal.toString()}",
              );
              total += item['paid'] as int;
            }
            print("Total expenses from search = $total฿");
          }
        } else {
          print("Error: ${response.statusCode}");
        }
        print('');
        break;
      case "4": //Add new expense

        print('');
        break;
      case "5": //Delete an expense

        print('');
        break;
      case "6": //Exit
        print("------- Bye -------");
        return false;
      default:
        print("Please enter 1-6");
    }
  }
}
