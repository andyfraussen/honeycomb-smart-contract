# honeycomb-smart-contract
## How-to install

### Run these commands in the project directory
1. composer install
2. cp .env.example .env
3. touch database/database.sqlite
4. php artisan:key generate
5. php artisan migrate
6. php artisan db:seed
7. php artisan serve
