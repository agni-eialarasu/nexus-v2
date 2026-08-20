import 'package:flutter_test/flutter_test.dart';
import 'package:nexus/models/permissions.dart';

void main() {
  group('UserPermissions', () {
    test('org admin has full access to all pages', () {
      final perms = UserPermissions.fullAccess();

      expect(perms.isOrgAdmin, isTrue);
      expect(perms.hasPageAccess('dashboard'), isTrue);
      expect(perms.hasPageAccess('projects'), isTrue);
      expect(perms.hasPageAccess('any_page'), isTrue);
      expect(perms.hasPageEdit('projects'), isTrue);
      expect(perms.getViewMode('projects'), ViewMode.global);
    });

    test('none permissions denies all access', () {
      final perms = UserPermissions.none();

      expect(perms.isOrgAdmin, isFalse);
      expect(perms.hasPageAccess('dashboard'), isFalse);
      expect(perms.hasPageEdit('projects'), isFalse);
      expect(perms.getViewMode('projects'), ViewMode.own);
    });

    test('resolves role permissions correctly', () {
      final perms = UserPermissions.resolve(
        rolePermissions: {
          'pages': {
            'dashboard': {'view': true, 'edit': false, 'viewMode': 'global'},
            'projects': {'view': true, 'edit': true, 'viewMode': 'team'},
          },
        },
      );

      expect(perms.hasPageAccess('dashboard'), isTrue);
      expect(perms.hasPageEdit('dashboard'), isFalse);
      expect(perms.getViewMode('dashboard'), ViewMode.global);

      expect(perms.hasPageAccess('projects'), isTrue);
      expect(perms.hasPageEdit('projects'), isTrue);
      expect(perms.getViewMode('projects'), ViewMode.team);

      // Unassigned page
      expect(perms.hasPageAccess('financials'), isFalse);
    });

    test('user overrides take precedence over role', () {
      final perms = UserPermissions.resolve(
        rolePermissions: {
          'pages': {
            'projects': {'view': true, 'edit': false, 'viewMode': 'team'},
          },
        },
        userOverrides: {
          'pages': {
            'projects': {'view': true, 'edit': true, 'viewMode': 'global'},
          },
        },
      );

      // User override wins
      expect(perms.hasPageEdit('projects'), isTrue);
      expect(perms.getViewMode('projects'), ViewMode.global);
    });
  });

  group('PagePermission', () {
    test('fromJson parses correctly', () {
      final perm = PagePermission.fromJson({
        'view': true,
        'edit': true,
        'viewMode': 'team',
      });

      expect(perm.view, isTrue);
      expect(perm.edit, isTrue);
      expect(perm.viewMode, ViewMode.team);
    });

    test('fromJson handles missing fields with defaults', () {
      final perm = PagePermission.fromJson({});

      expect(perm.view, isFalse);
      expect(perm.edit, isFalse);
      expect(perm.viewMode, ViewMode.own);
    });
  });
}
