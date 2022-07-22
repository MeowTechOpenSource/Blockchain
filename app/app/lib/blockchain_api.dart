import 'dart:convert';
import 'package:app/model/block.dart';
import 'package:app/shared_variables.dart';
import 'package:http/http.dart' as http;

class BlockchainAPI {
  static String _endpoint = SharedVars.blockchainUrl;

  static Stream<List<Block>> chainStream() {
    return Stream.periodic(Duration(seconds: 1)).asyncMap((_) => _getChain());
  }

  static Future<List<Block>> _getChain() async {
    final url = Uri.parse("$_endpoint/all_blocks");

    try {
      final response =
          await http.get(url, headers: {'Content-Type': "application/json"});

      List<Block> blocks = [];

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final chain = body['chain'];

        int id = 1;
        for (Map block in chain) {
          String from = block['transaction']['from'] == '_'
              ? 'System'
              : block['transaction']['from'];

          String to = block['transaction']['to'] == '_'
              ? 'System'
              : block['transaction']['to'];

          blocks.add(Block(
              from: from,
              to: to,
              amount: double.parse(block['transaction']['amount'].toString()),
              nonce: block['nonce'],
              timestamp: double.parse(block['timestamp'].toString()),
              hash: block['hash'],
              prevHash: block['prev_hash'],
              id: id));

          id += 1;
        }
      }
      return blocks;
    } catch (err) {
      return [];
    }
  }
}
