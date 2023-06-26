from rest_framework import viewsets
from rest_framework.views import APIView
from rest_framework.response import Response
from otus.kubernetes.models import User
from otus.kubernetes.serializers import UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = User.objects.all().order_by('name')
    serializer_class = UserSerializer


class HealtCheck(APIView):
    def get(self, request, format=None):
        return Response({'status': 'OK'})