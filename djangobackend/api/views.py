from django.contrib.auth.hashers import check_password
import json
from datetime import datetime
from django.http import JsonResponse
from rest_framework.decorators import api_view
from django.shortcuts import get_object_or_404
from rest_framework.generics import ListAPIView
from django.views.decorators.csrf import csrf_exempt
from .models import Store, Sale, Product, Stock, Wholesale, Supplier, Item, Wholesale_Items
from .serializers import UserSerializer, StoreSerializer, SaleSerializer, ProductSerializer, StockSerializer, WholesaleItemsSerializer, WholesaleSerializer, SupplierSerializer, ItemSerializer
from django.contrib.auth.models import User
from rest_framework.response import Response
from .serializers import ProductSerializer


@csrf_exempt
def login(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        try:
            user = User.objects.get(username=username)
            serializer = UserSerializer(user)
            if check_password(password, user.password):
                return JsonResponse({
                    'success': True,
                    'is_superuser': user.is_superuser,
                })
            else:
                return JsonResponse({'success': False, 'message': 'Invalid password'})
        except User.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'User does not exist'})
    else:
        return JsonResponse({'status': 'error'})


class UserList(ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class StoreList(ListAPIView):
    queryset = Store.objects.all()
    serializer_class = StoreSerializer


class SaleList(ListAPIView):
    queryset = Sale.objects.all()
    serializer_class = SaleSerializer


class ItemList(ListAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer


class StockList(ListAPIView):
    queryset = Stock.objects.all()
    serializer_class = StockSerializer


class ProductList(ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer


class WholesaleList(ListAPIView):
    queryset = Wholesale.objects.all()
    serializer_class = WholesaleSerializer


class WholesaleItemsList(ListAPIView):
    queryset = Wholesale_Items.objects.all()
    serializer_class = WholesaleItemsSerializer


class SupplierList(ListAPIView):
    queryset = Supplier.objects.all()
    serializer_class = SupplierSerializer


@api_view(['POST'])
def add_products(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        serializer = ProductSerializer(data)
        product_name = data['product_name']

        try:
            supplier_name = data['supplier']
            supplier = Supplier.objects.get(full_name=supplier_name)
        except Supplier.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Supplier does not exist'})

        if Product.objects.filter(product_name=product_name).exists():
            return JsonResponse({'success': False, 'message': 'Product already exists'})

        product = Product(
            product_name=product_name,
            supplier=supplier,
            warehouse_stock=data['warehouse_stock'],
            unit_price=data['unit_price'],
        )
        product.save()
        return JsonResponse({'success': True})
    else:
        return JsonResponse({'success': False, 'message': 'Invalid request method'})


@csrf_exempt
def delete_product(request, pk):

    product = get_object_or_404(Product, pk=pk)
    print(product)
    if request.method == 'DELETE':
        product.delete()
        return Response(status=204)


@api_view(['DELETE'])
def delete_supplier(request, pk):
    supplier = get_object_or_404(Product, pk=pk)
    supplier.delete()
    return Response(status=204)


@api_view(['DELETE'])
def delete_sale(request, pk):
    sale = get_object_or_404(Sale, pk=pk)
    sale.delete()
    return Response(status=204)


@api_view(['POST'])
def add_suppliers(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        serializer = SupplierSerializer(data)
        supplier_name = data['full_name']

        if Supplier.objects.filter(full_name=supplier_name).exists():
            return JsonResponse({'success': False, 'message': 'Supplier already exists'})

        supplier = Supplier(
            full_name=supplier_name,
            address=data['address'],
            email=data['email'],
            phone=data['phone'],
        )
        supplier.save()
        return JsonResponse({'success': True})
    else:
        return JsonResponse({'success': False, 'message': 'Invalid request method'})


@api_view(['DELETE'])
def delete_user(request, pk):
    user = get_object_or_404(User, pk=pk)
    user.delete()
    return Response(status=204)


@api_view(['POST'])
def add_users(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        serializer = UserSerializer(data)
        username = data['username']

        if User.objects.filter(username=username).exists():
            return JsonResponse({'success': False, 'message': 'Supplier already exists'})

        supplier = User(
            username=username,
            first_name=data['first_name'],
            last_name=data['last_name'],
            email=data['email'],
            password=data['password']
        )
        supplier.save()
        return JsonResponse({'success': True})
    else:
        return JsonResponse({'success': False, 'message': 'Invalid request method'})


@api_view(['POST'])
def get_product(request, product_name=None):
    if request.method == 'GET':
        if product_name:
            try:
                product = Product.objects.get(product_name=product_name)
                return JsonResponse({
                    'product_name': product.product_name,
                    'unit_price': product.unit_price
                })
            except Product.DoesNotExist:
                return JsonResponse({'error': 'Product not found'}, status=404)
        else:
            products = Product.objects.all().values('product_name', 'unit_price')
            return JsonResponse(list(products), safe=False)


@api_view(['PATCH'])
def edit_store_stock(request, pk):
    try:
        stock = Stock.objects.get(pk=pk)
        data = request.data
        if 'store_stock' in data:
            stock.store_stock = data['store_stock']
            stock.date = datetime.now()
        stock.save()
        return Response({'success': True, 'message': 'Stock updated successfully'})
    except Stock.DoesNotExist:
        return Response({'success': False, 'message': 'Invalid request method'})


@api_view(['PATCH'])
def update_product_stock(request, pk):
    try:
        product = Product.objects.get(pk=pk)
        data = request.data
        if 'warehouse_stock' in data:
            product.warehouse_stock = data['warehouse_stock']
        product.save()
        return Response({'success': True, 'message': 'Stock updated successfully'})
    except Product.DoesNotExist:
        return Response({'success': False, 'message': 'Invalid request method'})


@csrf_exempt
def add_sales(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        date = data['date']
        no_of_items = data['no_of_items']
        products = data['products']
        customer_id = data['customer_id']

        total_price = 0
        sale = Sale(
            customer_id=customer_id,
            date=date,
            no_of_items=no_of_items,
            total_price=total_price
        )
        sale.save()

        for product in products:
            product_name = product['name']
            quantity = product['quantity']
            try:
                product = Product.objects.get(product_name=product_name)
            except Product.DoesNotExist:
                return JsonResponse({'success': False, 'message': f'Product {product_name} not found'})
            unit_price = product.unit_price
            product_total_price = unit_price * quantity
            total_price += product_total_price
            item = Item(
                sale=sale,
                product=product,
                quantity=quantity,
                unit_price=unit_price,
                product_total_price=product_total_price
            )
            item.save()

        sale.total_price = total_price
        sale.save()

        return JsonResponse({'success': True, 'message': 'Saved Successfully'})
    else:
        return JsonResponse({'success': False, 'message': 'Invalid request method'})


@csrf_exempt
def add_wholesales(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        date = data['date']
        no_of_items = data['no_of_items']
        products = data['products']
        store_name = data['store']
        try:
            store = Store.objects.get(store_name=store_name)
        except Store.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Store not found'})

        total_price = 0
        wholesale = Wholesale(
            store=store,
            date=date,
            no_of_items=no_of_items,
            total_price=total_price
        )
        wholesale.save()

        for product in products:
            product_name = product['name']
            quantity = product['quantity']
            try:
                product = Product.objects.get(product_name=product_name)
            except Product.DoesNotExist:
                return JsonResponse({'success': False, 'message': f'Product {product_name} not found'})
            unit_price = product.unit_price
            product_total_price = unit_price * quantity
            total_price += product_total_price
            wholesale_items = Wholesale_Items(
                wholesale=wholesale,
                product=product,
                quantity=quantity,
                unit_price=unit_price,
                product_total_price=product_total_price
            )
            wholesale_items.save()

            product.warehouse_stock -= quantity
            product.save()

        wholesale.total_price = total_price
        wholesale.save()

        return JsonResponse({'success': True, 'message': 'Saved Successfully'})
    else:
        return JsonResponse({'success': False, 'message': 'Invalid request method'})
