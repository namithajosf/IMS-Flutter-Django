from rest_framework import serializers
from .models import Store, Sale, Item, Stock, Product, Supplier, Wholesale, Wholesale_Items
from django.contrib.auth.models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name',
                  'last_name', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}


class StoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Store
        fields = '__all__'


class SaleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sale
        fields = '__all__'


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = '__all__'


class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'


class StockSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stock
        fields = '__all__'


class SupplierSerializer(serializers.ModelSerializer):
    class Meta:
        model = Supplier
        fields = '__all__'


class WholesaleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wholesale
        fields = '__all__'


class WholesaleItemsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wholesale_Items
        fields = '__all__'
