# Generated by Django 4.1.7 on 2023-04-28 13:22

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0002_stock_date'),
    ]

    operations = [
        migrations.RenameField(
            model_name='sale',
            old_name='quantity',
            new_name='no_of_items',
        ),
        migrations.RemoveField(
            model_name='sale',
            name='product',
        ),
        migrations.RemoveField(
            model_name='sale',
            name='unit_price',
        ),
        migrations.CreateModel(
            name='Item',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('unit_price', models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ('quantity', models.IntegerField(default=0)),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='api.product', to_field='product_name')),
                ('sale', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='api.sale')),
            ],
        ),
    ]
