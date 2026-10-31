import 'package:flutter/material.dart';

import '../../models/github_user.dart';
import '../../state/github_controller.dart';
import '../widgets/status_badge.dart';
import '../../models/github_repo.dart';

class GitHubTab extends StatefulWidget {
  final GitHubController controller;

  const GitHubTab({super.key, required this.controller});

  @override
  State<GitHubTab> createState() => _GitHubTabState();
}

class _GitHubTabState extends State<GitHubTab> {
  final _usernameController = TextEditingController(text: 'flutter');
  final _tokenController = TextEditingController();
  final _repositoryController =
      TextEditingController(); //Controlador de texto ingresado
  bool _obscureToken = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _tokenController.dispose();
    _repositoryController.dispose();
    super.dispose();
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final token = _tokenController.text.trim();

    if (username.isEmpty && token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username or an Auth Token.'),
        ),
      );
      return;
    }

    widget.controller.fetchUser(
      username: username.isNotEmpty ? username : null,
      token: token.isNotEmpty ? token : null,
    );
  }

  //Metodo para iniciar la busqueda del controlador
  void _searchRepositories() {
    final query = _repositoryController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a repository search query.'),
        ),
      );
      return;
    }

    widget.controller.searchRepositories(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final user = widget.controller.user;
        final isLoading = widget.controller.isLoading;
        final errorMessage = widget.controller.errorMessage;
        final lastStatusCode = widget.controller.lastStatusCode;
        final repos = widget.controller.repos;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              Card(
                elevation: 0,
                color: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.code_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'GitHub REST API',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Type: Public + Authenticated (Bearer Token)\nEndpoints: /users/{username} or /user',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Presets
              Text(
                'Test Presets (Authentication & Status Codes)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    label: const Text('flutter (200 OK - No Auth)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _usernameController.text = 'flutter';
                            _tokenController.clear();
                            widget.controller.loadFlutterUser();
                          },
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    label: const Text('torvalds (200 OK - No Auth)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _usernameController.text = 'torvalds';
                            _tokenController.clear();
                            widget.controller.loadTorvaldsUser();
                          },
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.search_off_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    label: const Text('Non-existent (404 Not Found)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _usernameController.text =
                                'non-existent-user-test-xyz-999';
                            _tokenController.clear();
                            widget.controller.loadNonExistentUser();
                          },
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.lock_person_outlined,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    label: const Text('Invalid Token (401 Unauthorized)'),
                    onPressed: isLoading
                        ? null
                        : () {
                            _usernameController.clear();
                            _tokenController.text =
                                'ghp_invalid_dummy_token_1234567890';
                            widget.controller.loadInvalidAuthToken();
                          },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Custom Input Fields
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'GitHub Username (Public access)',
                  hintText: 'e.g. flutter, dart-lang, octocat',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _tokenController,
                obscureText: _obscureToken,
                decoration: InputDecoration(
                  labelText:
                      'Bearer Auth Token (Optional for protected routes)',
                  hintText: 'Personal Access Token (ghp_...)',
                  prefixIcon: const Icon(Icons.key_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureToken ? Icons.visibility_off : Icons.visibility,
                    ),
                    tooltip: 'Toggle Token Visibility',
                    onPressed: () {
                      setState(() {
                        _obscureToken = !_obscureToken;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              FilledButton.icon(
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isLoading ? 'Sending Request...' : 'Send GitHub Request',
                ),
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 20),

              // Repository Search
              Text(
                'Public Repository Search',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Campo para ingresar el término de búsqueda de repositorios.
              TextField(
                controller: _repositoryController,
                decoration: const InputDecoration(
                  labelText: 'Search GitHub repositories',
                  hintText: 'example: flutter, machine learning, games',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _searchRepositories(),
              ),
              const SizedBox(height: 8),

              FilledButton.icon(
                icon: const Icon(Icons.search_rounded),
                label: const Text('Search Repositories'),
                onPressed: isLoading ? null : _searchRepositories,
              ),
              const SizedBox(height: 20),

              // Results & State
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Result & State Presentation',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatusBadge(statusCode: lastStatusCode, isLoading: isLoading),
                ],
              ),
              const SizedBox(height: 8),

              if (isLoading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Connecting to api.github.com...'),
                      ],
                    ),
                  ),
                )
              else if (errorMessage != null)
                Card(
                  color: (lastStatusCode == 401)
                      ? Colors.red.shade50
                      : Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: (lastStatusCode == 401)
                          ? Colors.red.shade400
                          : Colors.amber.shade400,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              (lastStatusCode == 401)
                                  ? Icons.lock_clock
                                  : Icons.warning_amber_rounded,
                              color: (lastStatusCode == 401)
                                  ? Colors.red.shade900
                                  : Colors.amber.shade900,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lastStatusCode == 401
                                  ? '401 Unauthorized (Auth Failed)'
                                  : lastStatusCode == 404
                                  ? '404 Not Found'
                                  : 'HTTP Error Occurred',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (lastStatusCode == 401)
                                    ? Colors.red.shade900
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            color: (lastStatusCode == 401)
                                ? const Color(0xFF7F1D1D)
                                : const Color(0xFF78350F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tip: Inspect the headers (including X-RateLimit) in the Network Console below.',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (user != null)
                _GitHubUserCard(user: user)
              else
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Select a preset or enter a username to test the GitHub API.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),

              // Repository Search Results
              const SizedBox(height: 20),

              Text(
                'Repository Search Results',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (repos.isEmpty)
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Search for public repositories to see the results here.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                // Muestra los repositorios encontrados mediante tarjetas.
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repos.length,
                  itemBuilder: (context, index) {
                    final repo = repos[index];

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.code_rounded, size: 30),
                        title: Text(
                          repo.name ?? 'Unnamed repository',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (repo.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(repo.description),
                            ],
                            const SizedBox(height: 8),

                            // Muestra la cantidad de estrellas del repositorio.
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${repo.stargazersCount} stars',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              repo.htmlUrl,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GitHubUserCard extends StatelessWidget {
  final GitHubUser user;

  const _GitHubUserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? user.login,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user.login}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (user.location != null &&
                          user.location!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.bio!,
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(label: 'Public Repos', count: user.publicRepos),
                _StatColumn(label: 'Followers', count: user.followers),
                _StatColumn(label: 'Following', count: user.following),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
