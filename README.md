eApplication Library
====================

Minimum Hosting Requirements
----------------------------
- PHP 5.4
- MySQL database (could be migrated to another PDO-compatible database)

Setup Instructions
------------------
- Download and install composer http://getcomposer.org/
- Run `composer install` in PHP cli to download vendor packages
- Create a MySQL database named 'eaplib'
- Run the SQL in `\app\eaplib-migrate.sql` to set up database
- Set the database configuration details under the `Configure Idiorm` section in `\index.php`
- Copy the stored script from `\app\isis-stored-script.vbs` and run in ISIS
- Run the PHP server and navigate to `\index.php`
- Download the generated XML file from ISIS 'My User Area' and upload through Maintenance\Import Data in the library
- If password access is required, create an Apache `.htpasswd` file in root and uncomment first four lines of `.htaccess` file

Vendor Code Libraries Used (with Composer)
-----------------------------------
- Slim PHP Framework (routing)
- Idiorm and Paris (database object model)
- Twig (templating language)
- jQuery (JavaScript library)
- Twitter Bootstrap (base styles)
- PHPExcel (import CSV and XLS, XSLX)
- PHPSQLFormat (PHP SQL formatting library)
- ZeroClipboard (JavaScript clipboard library)
- DataTables (JavaScript table sorting library)