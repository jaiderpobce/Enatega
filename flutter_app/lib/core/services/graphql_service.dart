import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'storage_service.dart';

class GraphQLService {
  GraphQLService({required this.storageService}) {
    initClient();
  }

  static String get endpoint {
    if (kIsWeb) {
      return 'http://localhost:8081/graphql';
    }
    // Android emulator loops back to host localhost via 10.0.2.2
    return 'http://10.0.2.2:8081/graphql';
  }

  final StorageService storageService;
  late GraphQLClient _client;

  GraphQLClient get client => _client;

  void initClient() {
    final httpLink = HttpLink(endpoint);

    final authLink = AuthLink(
      getToken: () async {
        final token = storageService.getToken();
        if (token != null && token.isNotEmpty) {
          return 'Bearer $token';
        }
        return null;
      },
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  Future<QueryResult> query(
    String queryDoc, {
    Map<String, dynamic> variables = const {},
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(queryDoc),
        variables: variables,
        fetchPolicy: fetchPolicy,
      );
      return await _client.query(options);
    } catch (e) {
      debugPrint('GraphQL Query Error: $e');
      rethrow;
    }
  }

  Future<QueryResult> mutate(
    String mutationDoc, {
    Map<String, dynamic> variables = const {},
  }) async {
    try {
      final options = MutationOptions(
        document: gql(mutationDoc),
        variables: variables,
      );
      return await _client.mutate(options);
    } catch (e) {
      debugPrint('GraphQL Mutation Error: $e');
      rethrow;
    }
  }

  Future<void> updateToken(String token) async {
    await storageService.setToken(token);
    initClient();
  }

  Future<void> clearToken() async {
    await storageService.removeToken();
    initClient();
  }
}
