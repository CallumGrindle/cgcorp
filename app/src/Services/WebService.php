<?php

namespace App\Services;


use Symfony\Component\HttpFoundation\Response;
use Twig\Environment;

class WebService
{
    private Environment $twig;

    public function __construct(Environment $twig)
    {
        $this->twig = $twig;
    }

    public function renderResponse($view, $args)
    {
        $coreArgs = $this->getCoreArgs();
        $argsToRender = array_merge($coreArgs, $args);

        return new Response($this->twig->render($view, $argsToRender));
    }

    private function getCoreArgs(): array
    {
        return [
        ];
    }
}