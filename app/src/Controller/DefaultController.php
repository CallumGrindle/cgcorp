<?php


namespace App\Controller;


use Symfony\Component\HttpFoundation\JsonResponse;

class DefaultController
{
    public function __invoke()
    {
        return new JsonResponse([
            'test' => 'working'
        ]);
    }
}