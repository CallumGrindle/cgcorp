<?php

namespace App\Controller;

use App\Services\WebService;

class DefaultController
{
    private WebService $webService;

    public function __construct(WebService $webService)
    {
        $this->webService = $webService;
    }

    public function __invoke()
    {
        return $this->webService->renderResponse('base.html.twig', []);
    }
}