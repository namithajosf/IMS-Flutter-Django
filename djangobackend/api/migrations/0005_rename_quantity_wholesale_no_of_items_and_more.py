# Generated by Django 4.1.7 on 2023-05-01 16:54

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0004_remove_sale_store'),
    ]

    operations = [
        migrations.RenameField(
            model_name='wholesale',
            old_name='quantity',
            new_name='no_of_items',
        ),
        migrations.RemoveField(
            model_name='wholesale',
            name='product',
        ),
        migrations.RemoveField(
            model_name='wholesale',
            name='total_price',
        ),
        migrations.CreateModel(
            name='Wholesale_Items',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('unit_price', models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ('quantity', models.IntegerField(default=0)),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='api.product', to_field='product_name')),
                ('wholesale', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='api.wholesale')),
            ],
        ),
    ]
