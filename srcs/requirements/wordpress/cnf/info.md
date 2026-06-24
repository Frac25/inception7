# Viewing the `phpinfo()` Page

To display the PHP configuration information, you can create a temporary `info.php` file inside the WordPress container.

## 1. Access the WordPress container

```bash
docker exec -it wordpress sh
```

## 2. Go to the WordPress root directory

```bash
cd /var/www/html
```

## 3. Create the `info.php` file

```bash
echo '<?php phpinfo(); ?>' > /var/www/html/info.php
```

## 4. Open the page in your browser

Visit:

```text
https://sydubois.42.fr/info.php
```

If everything is configured correctly, the PHP information page will be displayed.

## Cleanup

For security reasons, remove the file once you have finished testing:

```bash
rm /var/www/html/info.php
```