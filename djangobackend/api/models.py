from django.contrib.auth import get_user_model
from django.db import models
from django.contrib.auth.models import User
from datetime import datetime

MyUser = get_user_model()


class Store(models.Model):
    store_name = models.CharField(max_length=100, unique=True)
    user = models.ForeignKey(
        MyUser, on_delete=models.CASCADE, to_field='username')

    def __str__(self):
        return self.store_name


class Supplier(models.Model):
    full_name = models.CharField(max_length=100, unique=True)
    address = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.CharField(max_length=10)

    def __str__(self):
        return self.full_name


class Product(models.Model):
    supplier = models.ForeignKey(
        Supplier, on_delete=models.CASCADE, to_field='full_name')
    product_name = models.CharField(max_length=100, unique=True)
    warehouse_stock = models.IntegerField(default=0)
    unit_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)

    def __str__(self):
        return self.product_name


class Sale(models.Model):
    customer_id = models.CharField(max_length=100)
    date = models.DateTimeField(default=datetime.now)
    no_of_items = models.IntegerField(default=0)
    total_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)

    def __str__(self):
        return self.customer_id


class Item(models.Model):
    sale = models.ForeignKey(Sale, on_delete=models.CASCADE)
    product = models.ForeignKey(
        Product, on_delete=models.CASCADE, to_field='product_name')
    unit_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)
    quantity = models.IntegerField(default=0)
    product_total_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)

    def save(self, *args, **kwargs):
        if not self.unit_price:
            self.unit_price = self.product.unit_price
        super().save(*args, **kwargs)


class Stock(models.Model):
    store = models.ForeignKey(
        Store, on_delete=models.CASCADE, to_field='store_name')
    product = models.ForeignKey(
        Product, on_delete=models.CASCADE, to_field='product_name')
    store_stock = models.IntegerField(default=0)
    date = models.DateTimeField(default=datetime.now)

    def __str__(self):
        return self.date.strftime('%Y-%m-%d')


class Wholesale(models.Model):
    store = models.ForeignKey(
        Store, on_delete=models.CASCADE, to_field='store_name')
    date = models.DateTimeField(default=datetime.now)
    no_of_items = models.IntegerField(default=0)
    total_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)

    def __str__(self):
        return self.wholesale_id


class Wholesale_Items(models.Model):
    wholesale = models.ForeignKey(Wholesale, on_delete=models.CASCADE)
    product = models.ForeignKey(
        Product, on_delete=models.CASCADE, to_field='product_name')
    unit_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)
    quantity = models.IntegerField(default=0)
    product_total_price = models.DecimalField(
        decimal_places=2, max_digits=10, default=0)
