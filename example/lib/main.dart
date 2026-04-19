import 'package:flutter/material.dart';
import 'models/user.dart';
import 'services/json_parse_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Convert Generator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String demonstrationLog = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _runDemo();
  }

  Future<void> _runDemo() async {
    final log = StringBuffer();

    // Demo 1: 从内存 Map 解析单个对象
    log.writeln('=== Demo 1: 从 Map 解析单个 User ===\n');
    final User? user = ParseFromMapExample.parseUser();
    log.writeln(
      'id=${user?.id}, name=${user?.name}, email=${user?.email}, age=${user?.age}\n',
    );

    // Demo 2: 从内存 List 解析对象列表
    log.writeln('=== Demo 2: 从 List 解析 List<User> ===\n');
    final List<User>? userList = ParseListFromMapExample.parseUserList();
    log.writeln('共解析 ${userList?.length} 个用户:');
    userList?.forEach(
      (u) => log.writeln('  - [${u.id}] ${u.name} (${u.email})'),
    );
    log.writeln('');

    // Demo 3: 解析 ApiResponse<User>（泛型为单个对象）
    log.writeln('=== Demo 3: 解析 ApiResponse<User>（泛型为对象）===\n');
    final apiUser = ParseApiResponseExample.parseApiResponseUser();
    log.writeln('code=${apiUser?.code}, message=${apiUser?.message}');
    log.writeln(
      'data: id=${apiUser?.data?.id}, name=${apiUser?.data?.name}, age=${apiUser?.data?.age}\n',
    );

    // Demo 4: 解析 ApiResponse<List<User>>（泛型为列表）
    log.writeln('=== Demo 4: 解析 ApiResponse<List<User>>（泛型为列表）===\n');
    final apiUserList = ParseApiResponseExample.parseApiResponseUserList();
    log.writeln('code=${apiUserList?.code}, message=${apiUserList?.message}');
    log.writeln('data 共 ${apiUserList?.data?.length} 个用户:');
    apiUserList?.data?.forEach(
      (u) => log.writeln('  - [${u.id}] ${u.name} ${u.email}'),
    );
    log.writeln('');

    // Demo 5: 从 assets 读取并解析 ApiResponse<User>
    log.writeln('=== Demo 5: 从 assets 解析 ApiResponse<User> ===\n');
    final assetApiUser = await ParseFromAssetsExample.loadApiResponseUser();
    log.writeln('code=${assetApiUser?.code}, message=${assetApiUser?.message}');
    log.writeln(
      'data: id=${assetApiUser?.data?.id}, name=${assetApiUser?.data?.name}, age=${assetApiUser?.data?.age}\n',
    );

    // Demo 6: 从 assets 读取并解析 ApiResponse<List<User>>
    log.writeln('=== Demo 6: 从 assets 解析 ApiResponse<List<User>> ===\n');
    final assetApiUserList =
        await ParseFromAssetsExample.loadApiResponseUserList();
    log.writeln(
      'code=${assetApiUserList?.code}, message=${assetApiUserList?.message}',
    );
    log.writeln('data 共 ${assetApiUserList?.data?.length} 个用户:');
    assetApiUserList?.data?.forEach(
      (u) => log.writeln('  - [${u.id}] ${u.name} (${u.email})'),
    );
    log.writeln('');

    // Demo 7: 解析复杂嵌套数据结构
    log.writeln('=== Demo 7: 解析复杂嵌套数据结构 ===\n');
    final nestedResult =
        await ParseComplexNestedExample.loadComplexNestedData();
    log.writeln(
      'requestId=${nestedResult?.requestId}, team=${nestedResult?.payload.team.name}',
    );
    log.writeln(
      'owner: ${nestedResult?.payload.team.owner.name} (${nestedResult?.payload.team.owner.email})',
    );
    log.writeln(
      'activeUsers=${nestedResult?.payload.team.groups.active.length}, archivedUsers=${nestedResult?.payload.team.groups.archived.length}',
    );
    log.writeln(
      'primaryUser: ${nestedResult?.payload.recommendation.primaryUser.name}, backupUsers=${nestedResult?.payload.recommendation.backupUsers.length}',
    );
    log.writeln(
      'meta: total=${nestedResult?.meta.total}, hasNext=${nestedResult?.meta.hasNext}',
    );
    for (final user
        in nestedResult?.payload.team.groups.active ?? const <User>[]) {
      log.writeln('  - active [${user.id}] ${user.name}');
    }
    for (final user
        in nestedResult?.payload.recommendation.backupUsers ?? const <User>[]) {
      log.writeln('  - backup [${user.id}] ${user.name}');
    }
    log.writeln('');

    setState(() {
      demonstrationLog = log.toString();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Convert Generator Demo'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'JSON Conversion Demonstration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This demo shows how json_convert_generator automatically generates '
              'JSON conversion code for @JsonSerializable annotated classes.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Features section
            _buildFeatureCard(
              context,
              'Automatic Code Generation',
              'Scans @JsonSerializable and @freezed annotations',
              Icons.auto_awesome,
            ),
            _buildFeatureCard(
              context,
              'Type-Safe Conversion',
              'Generates type-safe JSON to Object mappings',
              Icons.verified_user,
            ),
            _buildFeatureCard(
              context,
              'List Support',
              'Handles both single objects and lists',
              Icons.list,
            ),
            const SizedBox(height: 24),

            // Demonstration output
            Text(
              'Live Demonstration Output:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _loading ? '加载并解析中...' : demonstrationLog,
                style: const TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Text('How to Use:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildInstruction(
              '1. Add @JsonSerializable() to your model classes',
            ),
            _buildInstruction('2. Run flutter pub get to resolve dependencies'),
            _buildInstruction(
              '3. Run build_runner: dart run build_runner build',
            ),
            _buildInstruction(
              '4. Generated files will be created automatically',
            ),
            _buildInstruction(
              '5. Import and use the generated json_convert_utils.dart',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
